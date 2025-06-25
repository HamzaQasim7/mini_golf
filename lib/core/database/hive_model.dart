// lib/core/models/game_models.dart
import 'dart:ui';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Game extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String courseName;

  @HiveField(2)
  int numberOfHoles;

  @HiveField(3)
  List<Player> players;

  @HiveField(4)
  List<List<HoleScore>> holes; // holes[holeIndex][playerIndex]

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? completedAt;

  @HiveField(7)
  int currentHole;

  @HiveField(8)
  bool isCompleted;

  Game({
    required this.id,
    required this.courseName,
    required this.numberOfHoles,
    required this.players,
    required this.holes,
    required this.createdAt,
    this.completedAt,
    this.currentHole = 1,
    this.isCompleted = false,
  });

  List<int> getTotalScores() {
    return players.asMap().entries.map((entry) {
      int playerIndex = entry.key;
      return holes.fold<int>(0, (sum, hole) {
        return sum + (hole[playerIndex].strokes);
      });
    }).toList();
  }

  Player? getWinner() {
    if (!isCompleted) return null;

    final totalScores = getTotalScores();
    final minScore = totalScores.reduce((a, b) => a < b ? a : b);
    final winnerIndex = totalScores.indexOf(minScore);

    // Check for tie
    final winners = totalScores.where((score) => score == minScore).length;
    if (winners > 1) return null; // Tie game

    return players[winnerIndex];
  }
}

@HiveType(typeId: 1)
class Player extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String colorHex;

  @HiveField(3)
  String? avatar;

  @HiveField(4)
  int handicap;

  @HiveField(5)
  DateTime createdAt;

  Player({
    required this.id,
    required this.name,
    required this.colorHex,
    this.avatar,
    this.handicap = 0,
    required this.createdAt,
  });

  Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
}

@HiveType(typeId: 2)
class Course extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String imageUrl;

  @HiveField(3)
  int holes;

  @HiveField(4)
  List<int> parValues; // Par for each hole

  Course({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.holes,
    required this.parValues,
  });
}

@HiveType(typeId: 3)
class HoleScore extends HiveObject {
  @HiveField(0)
  int strokes;

  @HiveField(1)
  int par;

  HoleScore({required this.strokes, required this.par});

  int get scoreRelativeToPar => strokes - par;

  String get scoreDescription {
    final diff = scoreRelativeToPar;
    if (diff <= -2) return 'Eagle';
    if (diff == -1) return 'Birdie';
    if (diff == 0) return 'Par';
    if (diff == 1) return 'Bogey';
    if (diff == 2) return 'Double Bogey';
    return '+${diff}';
  }
}
