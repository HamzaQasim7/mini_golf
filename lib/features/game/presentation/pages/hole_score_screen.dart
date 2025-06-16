import 'package:flutter/material.dart';
import 'package:mini_golf/features/game/presentation/pages/score_card_screen.dart';
import 'package:mini_golf/widgets/custom_button.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/player_model.dart';

class HoleScoreScreen extends StatefulWidget {
  final int holeNumber;
  final List<Player> players;

  const HoleScoreScreen({
    super.key,
    required this.holeNumber,
    required this.players,
  });

  @override
  State<HoleScoreScreen> createState() => _HoleScoreScreenState();
}

class _HoleScoreScreenState extends State<HoleScoreScreen> {
  final Map<String, String> scores = {};

  @override
  void initState() {
    super.initState();
    for (var player in widget.players) {
      scores[player.name] = '';
    }
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
        title: Text(
          'Hole ${widget.holeNumber}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Players',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.players.map((player) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Handicap: ${player.handicap}',
                        style: const TextStyle(
                          color: AppColors.greyB3,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              const Text(
                'Score',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...widget.players.map((player) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter score',
                      hintStyle: const TextStyle(color: AppColors.greyB3),
                      filled: true,
                      fillColor: const Color(0xFF1D2A23),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        scores[player.name] = value;
                      });
                    },
                    onTapOutside: (_) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                );
              }),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Previous',
                      backgroundColor: const Color(0xFF2A3B34),
                      textColor: Colors.white,
                      onPressed: () {
                        // Go back to previous hole or screen
                      },
                    ),
                  ),
                  Expanded(
                    child: CustomButton(
                      text: 'Next',
                      backgroundColor: AppColors.primary,
                      textColor: Colors.black,
                      onPressed: () {
                        // Save scores and navigate to next hole or summary
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScorecardScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
