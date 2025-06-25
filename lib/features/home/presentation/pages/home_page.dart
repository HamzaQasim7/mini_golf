import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mini_golf/features/game/presentation/pages/hole_score_screen.dart';
import 'package:mini_golf/features/game/presentation/providers/game_provider.dart';
import 'package:mini_golf/widgets/custom_button.dart';
import 'package:provider/provider.dart';

import '../../../game/presentation/pages/course_selection_screen.dart';
import 'package:mini_golf/features/game/presentation/pages/history_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
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
                            borderRadius: const BorderRadius.only(
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
                  const Gap(16),
                  Text(
                    'Welcome to Blast Zone',
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  const Gap(16),
                  if (gameProvider.hasActiveGame) ...[
                    CustomButton(
                      text: 'Resume Game',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HoleScoreScreen(
                              holeNumber: gameProvider.currentGame!.currentHole,
                            ),
                          ),
                        );
                      },
                      width: 300,
                    ),
                    const Gap(8),
                  ],
                  CustomButton(
                    text: gameProvider.hasActiveGame
                        ? 'Start New Game'
                        : 'Play Now',
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
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GameHistoryScreen()),
              );
            },
            child: const Icon(Icons.history),
          ),
        );
      },
    );
  }
}
