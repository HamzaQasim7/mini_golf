import 'package:flutter/material.dart';
import 'package:mini_golf/features/game/presentation/pages/score_card_screen.dart';
import 'package:mini_golf/widgets/custom_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/score_button.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class HoleScoreScreen extends StatefulWidget {
  final int holeNumber;

  const HoleScoreScreen({super.key, required this.holeNumber});

  @override
  State<HoleScoreScreen> createState() => _HoleScoreScreenState();
}

class _HoleScoreScreenState extends State<HoleScoreScreen> {
  late List<int> _scores;

  @override
  void initState() {
    super.initState();
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final currentGame = gameProvider.currentGame;

    if (currentGame != null) {
      final holeIndex = widget.holeNumber - 1;
      // Ensure holeIndex is valid
      if (holeIndex >= 0 && holeIndex < currentGame.holes.length) {
        // Initialize scores from the provider for the current hole
        _scores =
            currentGame.holes[holeIndex].map((score) => score.strokes).toList();
      } else {
        _scores = List.filled(currentGame.players.length, 0);
      }
    } else {
      // This case should not be reached in a normal flow
      _scores = [];
    }
  }

  void _incrementScore(int playerIndex) {
    setState(() {
      // Set a reasonable max score
      if (_scores[playerIndex] < 99) {
        _scores[playerIndex]++;
      }
    });
  }

  void _decrementScore(int playerIndex) {
    setState(() {
      if (_scores[playerIndex] > 0) {
        _scores[playerIndex]--;
      }
    });
  }

  Future<void> _saveScoresAndExit() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final currentGame = gameProvider.currentGame;
    if (currentGame == null) return;

    final holeIndex = widget.holeNumber - 1;

    // Save each player's score for the current hole
    for (int i = 0; i < _scores.length; i++) {
      await gameProvider.updateHoleScore(
        holeIndex: holeIndex,
        playerIndex: i,
        strokes: _scores[i],
      );
    }

    // Go back to the previous screen (e.g., Scorecard)
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final currentGame = gameProvider.currentGame;

        if (currentGame == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundDark,
            appBar: AppBar(title: const Text('Error')),
            body: const Center(
              child: Text(
                'No active game found.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final players = currentGame.players;
        final holeIndex = widget.holeNumber - 1;

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundDark,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text(
              'Hole ${widget.holeNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final par = currentGame.holes[holeIndex][index].par;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Player name and Par
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    players[index].name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Par $par',
                                    style: const TextStyle(
                                      color: AppColors.greyB3,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Score controls
                            Row(
                              children: [
                                ScoreButton(
                                  icon: Icons.remove,
                                  onTap: () => _decrementScore(index),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_scores[index]}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ScoreButton(
                                  icon: Icons.add,
                                  onTap: () => _incrementScore(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Back',
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        backgroundColor: const Color(0xFF2A3B34),
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Save & Exit',
                        backgroundColor: AppColors.primary,
                        textColor: Colors.black,
                        onPressed: _saveScoresAndExit,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
