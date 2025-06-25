import 'package:flutter/material.dart';
import 'package:mini_golf/features/game/presentation/pages/score_card_screen.dart';
import 'package:mini_golf/widgets/custom_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/score_button.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class HoleScoreScreen extends StatefulWidget {
  final int holeNumber;

  const HoleScoreScreen({super.key, this.holeNumber = 1});

  @override
  State<HoleScoreScreen> createState() => _HoleScoreScreenState();
}

class _HoleScoreScreenState extends State<HoleScoreScreen> {
  late List<int> scores;

  @override
  void initState() {
    super.initState();
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final players = gameProvider.currentGame?.players ?? [];
    scores = List.filled(players.length, 0);
  }

  void _incrementScore(int index) {
    setState(() {
      scores[index]++;
    });
  }

  void _decrementScore(int index) {
    setState(() {
      if (scores[index] > 0) {
        scores[index]--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final players = gameProvider.currentGame?.players ?? [];

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
            ...List.generate(players.length, (index) {
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
                            'Player ${index + 1}: ${players[index].name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Par 3',
                            style: TextStyle(
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
                          '${scores[index]}',
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
            }),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Previous',
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
                Expanded(
                  child: CustomButton(
                    text: 'Next',
                    backgroundColor: AppColors.primary,
                    textColor: Colors.black,
                    onPressed: () async {
                      final gameProvider = Provider.of<GameProvider>(
                        context,
                        listen: false,
                      );
                      final players = gameProvider.currentGame?.players ?? [];
                      final Map<String, int> playerScores = {
                        for (int i = 0; i < players.length; i++)
                          players[i].id: scores[i],
                      };

                      await gameProvider.addHoleScores(
                        widget.holeNumber,
                        playerScores,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ScorecardScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
