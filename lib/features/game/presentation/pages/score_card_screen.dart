import 'package:flutter/material.dart';
import 'package:mini_golf/widgets/custom_button.dart';

import '../widgets/score_entry.dart';
import '../widgets/tie_message.dart';

class ScorecardScreen extends StatelessWidget {
  const ScorecardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E28), // Dark background from image
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E28),
        // Match screen background
        elevation: 0,
        // No shadow under app bar
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white), // 'X' icon
          onPressed: () {
            Navigator.pop(context); // Example: Close the screen
          },
        ),
        title: const Text(
          'Scorecard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Final Score',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),

              // Player Scores
              const ScoreEntry(
                playerName: 'Liam',
                holes: '18 Holes',
                score: 54,
              ),
              const ScoreEntry(
                playerName: 'Noah',
                holes: '18 Holes',
                score: 54,
              ),
              const ScoreEntry(
                playerName: 'Ethan',
                holes: '18 Holes',
                score: 56,
              ),
              const ScoreEntry(
                playerName: 'Oliver',
                holes: '18 Holes',
                score: 58,
              ),

              const SizedBox(height: 20.0),
              // Spacing before the message

              // Tie Message
              const TieMessage(
                message:
                    'Liam and Noah tied! Play another round to determine the winner.',
              ),

              const SizedBox(height: 60.0),
              // Flexible space before the button, push button to bottom

              // Play Again Button (positioned at the bottom using Flexible/Spacer in a real app,
              // but for a simple column, a large SizedBox pushes it down if content is short)
              CustomButton(text: 'Play Again', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
