import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mini_golf/features/game/presentation/pages/add_player_screen.dart';
import 'package:mini_golf/features/game/presentation/providers/game_provider.dart';
import 'package:mini_golf/widgets/custom_button.dart';
import 'package:mini_golf/widgets/shared_dynamic_icon.dart';
import 'package:provider/provider.dart';

import '../../../game/presentation/pages/course_selection_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Stack(
                  children: [
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/images/aliens.png',

                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/images/mini-golf-icon.png',
                        height: 100,
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),

              Gap(16),
              Text(
                'Welcome to Blast Zone',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gap(8),
              CustomButton(
                text: 'Play Now',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CourseSelectionScreen(),
                    ),
                  );
                },
                width: 300,
              ),
              const Gap(16),
              // CustomButton(
              //   text: 'View History',
              //   onPressed: () async {
              //     final gameProvider = Provider.of<GameProvider>(context, listen: false);
              //     try {
              //       final games = await gameProvider.getAllGames();
              //       if (mounted) {
              //         // Navigate to history screen (you'll need to create this)
              //         // Navigator.push(
              //         //   context,
              //         //   MaterialPageRoute(builder: (_) => GameHistoryScreen(games: games)),
              //         // );
              //       }
              //     } catch (e) {
              //       if (mounted) {
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           SnackBar(
              //             content: Text('Failed to load game history: $e'),
              //             backgroundColor: Colors.red,
              //           ),
              //         );
              //       }
              //     }
              //   },
              //   width: 300,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
