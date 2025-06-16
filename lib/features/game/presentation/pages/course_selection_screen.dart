import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/hole_option_button.dart';
import 'add_player_screen.dart';

class CourseSelectionScreen extends StatefulWidget {
  const CourseSelectionScreen({super.key});

  @override
  State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  String courseName = '';
  int selectedHoles = 9;

  void _selectHoles(int holes) {
    setState(() {
      selectedHoles = holes;
    });
  }

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Course Name (optional)',
                hintStyle: const TextStyle(color: AppColors.greyB3),
                filled: true,
                fillColor: const Color(0xFF1D2A23),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => courseName = value,
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Number of Holes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                HoleOptionButton(
                  label: '9 Holes',
                  isSelected: selectedHoles == 9,
                  onTap: () => _selectHoles(9),
                ),
                const SizedBox(width: 12),
                HoleOptionButton(
                  label: '18 Holes',
                  isSelected: selectedHoles == 18,
                  onTap: () => _selectHoles(18),
                ),
              ],
            ),
            const Spacer(),
            CustomButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const AddPlayersScreen(
                        courseName: '',
                        numberOfHoles: null,
                      );
                    },
                  ),
                );
              },
              text: 'Start Game',
            ),
          ],
        ),
      ),
    );
  }
}
