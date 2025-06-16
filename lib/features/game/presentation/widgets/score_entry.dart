import 'package:flutter/material.dart';

class ScoreEntry extends StatelessWidget {
  final String playerName;
  final String holes;
  final int score;
  final Color? playerNameColor;
  final Color? holesColor;
  final Color? scoreColor;
  final double playerNameFontSize;
  final double holesFontSize;
  final double scoreFontSize;
  final EdgeInsetsGeometry padding;

  const ScoreEntry({
    super.key,
    required this.playerName,
    required this.holes,
    required this.score,
    this.playerNameColor = Colors.white,
    this.holesColor = Colors.white70,
    this.scoreColor = Colors.white,
    this.playerNameFontSize = 18.0,
    this.holesFontSize = 14.0,
    this.scoreFontSize = 18.0,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playerName,
                style: TextStyle(
                  color: playerNameColor,
                  fontSize: playerNameFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                holes,
                style: TextStyle(color: holesColor, fontSize: holesFontSize),
              ),
            ],
          ),
          Text(
            score.toString(),
            style: TextStyle(
              color: scoreColor,
              fontSize: scoreFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
