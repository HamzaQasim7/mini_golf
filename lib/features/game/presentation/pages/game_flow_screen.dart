// lib/features/game/presentation/pages/game_flow_screen.dart

import 'package:flutter/material.dart';
import 'spin_wheel_screen.dart';
import 'hole_score_screen.dart';

class GameFlowScreen extends StatefulWidget {
  final String courseName;
  final int numberOfHoles;
  final List<String> playerNames;

  const GameFlowScreen({
    super.key,
    required this.courseName,
    required this.numberOfHoles,
    required this.playerNames,
  });

  @override
  State<GameFlowScreen> createState() => _GameFlowScreenState();
}

class _GameFlowScreenState extends State<GameFlowScreen> {
  int currentHole = 1;
  String? currentTaskTitle;
  String? currentTaskDescription;

  void _onSpinComplete(String title, String description) {
    setState(() {
      currentTaskTitle = title;
      currentTaskDescription = description;
    });
    // After showing the task, proceed to the hole score screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HoleScoreScreen(
          holeNumber: currentHole,
          // Optionally pass the task info here
        ),
      ),
    ).then((_) {
      // After scoring, go to next hole or finish
      if (currentHole < widget.numberOfHoles) {
        setState(() {
          currentHole++;
          currentTaskTitle = null;
          currentTaskDescription = null;
        });
      } else {
        // Show final score screen or summary
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // If Crazy Mini Golf, show the wheel before each hole
    if (widget.courseName == "Crazy Mini Golf" && currentTaskTitle == null) {
      return SpinWheelScreen(
        onTaskSelected: (title, description) => _onSpinComplete(title, description),
      );
    }
    // Otherwise, go directly to scoring (for other courses)
    return HoleScoreScreen(
      holeNumber: currentHole,
    );
  }
}