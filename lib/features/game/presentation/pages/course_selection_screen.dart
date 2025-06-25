import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/custom_button.dart';
import '../providers/game_provider.dart';
import 'add_player_screen.dart';

class Course {
  final String name;
  final String imageUrl;
  final int holes;

  Course({required this.name, required this.imageUrl, required this.holes});
}

class CourseSelectionScreen extends StatefulWidget {
  const CourseSelectionScreen({super.key});

  @override
  State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: const CloseButton(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'New Game',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (gameProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${gameProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => gameProvider.refreshData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final courses = gameProvider.courses;
          if (courses.isEmpty) {
            return const Center(
              child: Text(
                'No courses available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Course',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // List of courses
                Expanded(
                  child: ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final isSelected = index == selectedIndex;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color(0xFF1D2A23)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                isSelected
                                    ? Border.all(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    )
                                    : null,
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                course.imageUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 48,
                                    height: 48,
                                    color: AppColors.greyB3,
                                    child: const Icon(
                                      Icons.golf_course,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                            title: Text(
                              course.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${course.holes} Holes',
                              style: const TextStyle(
                                color: AppColors.greyB3,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  onPressed: () {
                    final selectedCourse = courses[selectedIndex];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddPlayersScreen(
                              courseName: selectedCourse.name,
                              numberOfHoles: selectedCourse.holes,
                            ),
                      ),
                    );
                  },
                  text: 'Start Game',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// class CourseSelectionScreen extends StatefulWidget {
//   const CourseSelectionScreen({super.key});
//
//   @override
//   State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
// }
//
// class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
//   // Mocked list of courses
//   final List<Course> courses = [
//     Course(
//       name: 'Blastzone Mini Golf',
//       imageUrl: 'assets/images/mini-golf.jpg',
//       holes: 18,
//     ),
//     Course(
//       name: 'Crazy Mini Golf',
//       imageUrl: 'assets/images/crazy_mini_golf.jpg',
//       holes: 18,
//     ),
//   ];
//
//   int selectedIndex = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDark,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundDark,
//         elevation: 0,
//         leading: const CloseButton(color: Colors.white),
//         centerTitle: true,
//         title: const Text(
//           'New Game',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Course',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 16),
//             // List of courses
//             ...List.generate(courses.length, (index) {
//               final course = courses[index];
//               final isSelected = index == selectedIndex;
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     selectedIndex = index;
//                   });
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   decoration: BoxDecoration(
//                     color:
//                         isSelected
//                             ? const Color(0xFF1D2A23)
//                             : Colors.transparent,
//                     borderRadius: BorderRadius.circular(12),
//                     border:
//                         isSelected
//                             ? Border.all(color: AppColors.primary, width: 1.5)
//                             : null,
//                   ),
//                   child: ListTile(
//                     leading: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.asset(
//                         course.imageUrl,
//                         width: 48,
//                         height: 48,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     title: Text(
//                       course.name,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     subtitle: Text(
//                       '${course.holes} Holes',
//                       style: const TextStyle(
//                         color: AppColors.greyB3,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//             const Spacer(),
//             CustomButton(
//               onPressed: () {
//                 final selectedCourse = courses[selectedIndex];
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder:
//                         (context) => AddPlayersScreen(
//                           courseName: selectedCourse.name,
//                           numberOfHoles: selectedCourse.holes,
//                         ),
//                   ),
//                 );
//               },
//               text: 'Start Game',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
