import 'package:flutter/material.dart';
import 'package:mini_golf/widgets/app_lotties_animation.dart';
import 'package:mini_golf/widgets/custom_button.dart';
import '../../../../core/database/hive_model.dart';
import '../../../../core/theme/app_colors.dart';

class ScorecardScreen extends StatelessWidget {
  final Game game;

  const ScorecardScreen({super.key, required this.game});

  List<Map<String, dynamic>> _getLeaderboard(Game game) {
    final totalScores = game.getTotalScores();
    final leaderboard = <Map<String, dynamic>>[];

    for (int i = 0; i < game.players.length; i++) {
      leaderboard.add({
        'player': game.players[i],
        'totalScore': totalScores[i],
      });
    }
    leaderboard.sort((a, b) => a['totalScore'].compareTo(b['totalScore']));
    return leaderboard;
  }

  List<Player> _getWinners(List<Map<String, dynamic>> leaderboard) {
    if (leaderboard.isEmpty) return [];

    final minScore = leaderboard.first['totalScore'];
    return leaderboard
        .where((entry) => entry['totalScore'] == minScore)
        .map((entry) => entry['player'] as Player)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final leaderboard = _getLeaderboard(game);
    final winners = _getWinners(leaderboard);

    String winnerNames = winners.map((p) => p.name).join(' & ');
    bool isTie = winners.length > 1;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E28),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E28),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        title: const Text(
          'Scoreboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              if (leaderboard.isNotEmpty)
                const Text(
                  'Final Scores',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              const SizedBox(height: 20),
              ...leaderboard.map((entry) {
                final player = entry['player'] as dynamic;
                final score = entry['totalScore'] as int;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total: $score',
                        style: const TextStyle(
                          color: Color(0xFFB3B3B3),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 18),

              // Winner/Tie Section
              if (winners.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppLottieAnimation(
                        assetPath: 'assets/lottie/trophy.json',
                        height: 70,
                        fit: BoxFit.fitHeight,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isTie ? 'It\'s a Tie!' : ' Winner!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        winnerNames,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          shadows: [
                            Shadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Congratulations!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'You are the mini golf champion!',
                        style: TextStyle(
                          color: Color(0xFFB3B3B3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              CustomButton(
                text: 'New Game',
                backgroundColor: AppColors.primary,
                textColor: Colors.black,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
