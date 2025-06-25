import 'package:flutter/material.dart';
import 'package:mini_golf/widgets/app_lotties_animation.dart';
import 'package:mini_golf/widgets/custom_button.dart';
import '../../../../core/theme/app_colors.dart';

class ScorecardScreen extends StatefulWidget {
  final List<String> playerNames;
  final List<int> scores;

  const ScorecardScreen({
    super.key,
    required this.playerNames,
    required this.scores,
  });

  @override
  State<ScorecardScreen> createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends State<ScorecardScreen> {
  late List<Map<String, dynamic>> players;
  late List<String> winners;

  @override
  void initState() {
    super.initState();

    // Create player list
    players = List.generate(widget.playerNames.length, (i) {
      return {'name': widget.playerNames[i], 'score': widget.scores[i]};
    });

    // ✅ Use MINIMUM score instead of maximum
    int minScore = players
        .map((p) => p['score'] as int)
        .reduce((a, b) => a < b ? a : b);

    // ✅ Find winners based on minimum score
    winners =
        players
            .where((p) => p['score'] == minScore)
            .map((p) => p['name'] as String)
            .toList();

    // If it's a tie
    if (winners.length > 1) {
      winners = ['Withdraw'];
    }

    // Show winner animation (if not a tie)
    if (winners.first != 'Withdraw') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder:
              (context) => Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: AppLottieAnimation(
                  assetPath: 'assets/lottie/trophy.json',
                  height: 100,
                  width: 200,
                  fit: BoxFit.fitWidth,
                ),
              ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context, rootNavigator: true).pop();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String winnerNames = winners.join(' & ');

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E28),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E28),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
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
              const Text(
                'Final Scores',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 20),
              ...players.map(
                (player) => Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total: ${player['score']}',
                        style: const TextStyle(
                          color: Color(0xFFB3B3B3),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ✅ Winner/Tie Section
              if (winners.isNotEmpty && winners.first != 'Withdraw') ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppLottieAnimation(
                            assetPath: 'assets/lottie/basic-trophy.json',
                            height: 50,
                            width: 80,
                            fit: BoxFit.fitWidth,
                          ),
                          const Text(
                            ' Winner!',
                            style: TextStyle(
                              fontSize: 28,
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
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 8),
                      const Text(
                        'Congratulations!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'You are the mini golf champion!',
                        style: TextStyle(
                          color: Color(0xFFB3B3B3),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      "Game tied! Thank you for playing.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
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
