// lib/features/game/presentation/pages/game_flow_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import 'all_holes_score_entry_screen.dart';
import 'spin_wheel_screen.dart';

class GameFlowScreen extends StatelessWidget {
  const GameFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen acts as a router.
    // It checks the course type and decides the first screen to show for the game.
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final courseName = gameProvider.currentGame?.courseName;

    if (courseName == 'Crazy Mini Golf') {
      return SpinWheelScreen(
        onTaskSelected: (spinContext, title, description) {
          // After spinning the wheel, navigate to the full scorecard.
          Navigator.pushReplacement(
            spinContext,
            MaterialPageRoute(
              builder: (_) => const AllHolesScoreEntryScreen(),
            ),
          );

          // Show a SnackBar with the task for confirmation
          ScaffoldMessenger.of(spinContext).showSnackBar(
            SnackBar(
              content: Text('This Round\'s Task: $title'),
              backgroundColor: Colors.blueAccent,
            ),
          );
        },
      );
    } else {
      // For all other courses, go directly to the score entry screen.
      return const AllHolesScoreEntryScreen();
    }
  }
}