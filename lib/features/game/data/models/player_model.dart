import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String? id;
  final String courseName;
  final int numberOfHoles;
  final List<Player> players;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final DateTime? completedAt;
  final int currentHole;

  Game({
    this.id,
    required this.courseName,
    required this.numberOfHoles,
    required this.players,
    this.isCompleted = false,
    required this.createdAt,
    required this.lastUpdated,
    this.completedAt,
    this.currentHole = 1,
  });

  // Calculate total score for a player
  int getTotalScore(String playerName) {
    final player = players.firstWhere((p) => p.name == playerName);
    return player.scores.values.fold(0, (sum, score) => sum + score);
  }

  // Get winner(s) - returns list in case of tie
  List<Player> getWinners() {
    if (players.isEmpty) return [];

    final scores =
        players.map((p) => MapEntry(p, getTotalScore(p.name))).toList();
    scores.sort((a, b) => a.value.compareTo(b.value));

    final lowestScore = scores.first.value;
    return scores
        .where((entry) => entry.value == lowestScore)
        .map((entry) => entry.key)
        .toList();
  }

  // Check if game is complete
  bool get isGameComplete {
    return players.every((player) => player.scores.length == numberOfHoles);
  }

  // Get leaderboard
  List<MapEntry<Player, int>> getLeaderboard() {
    final scores =
        players.map((p) => MapEntry(p, getTotalScore(p.name))).toList();
    scores.sort((a, b) => a.value.compareTo(b.value));
    return scores;
  }

  Game copyWith({
    String? id,
    String? courseName,
    int? numberOfHoles,
    List<Player>? players,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? lastUpdated,
    DateTime? completedAt,
    int? currentHole,
  }) {
    return Game(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      numberOfHoles: numberOfHoles ?? this.numberOfHoles,
      players: players ?? this.players,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      completedAt: completedAt ?? this.completedAt,
      currentHole: currentHole ?? this.currentHole,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseName': courseName,
      'numberOfHoles': numberOfHoles,
      'players': players.map((p) => p.toMap()).toList(),
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'currentHole': currentHole,
    };
  }

  static Game fromMap(Map<String, dynamic> map, String id) {
    return Game(
      id: id,
      courseName: map['courseName'] ?? '',
      numberOfHoles: map['numberOfHoles'] ?? 9,
      players:
          (map['players'] as List<dynamic>?)
              ?.map((p) => Player.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      isCompleted: map['isCompleted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated:
          (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      currentHole: map['currentHole'] ?? 1,
    );
  }
}

// Enhanced Player Model
class Player {
  final String name;
  final String avatar;
  final int handicap;
  final String colorHex; // Store color as hex string
  final Map<int, int> scores; // hole number -> score

  Player({
    required this.name,
    required this.avatar,
    required this.handicap,
    required this.colorHex,
    this.scores = const {},
  });

  // Get total score
  int get totalScore => scores.values.fold(0, (sum, score) => sum + score);

  // Get score for specific hole
  int? getScoreForHole(int hole) => scores[hole];

  // Add/update score for a hole
  Player addScore(int hole, int score) {
    final newScores = Map<int, int>.from(scores);
    newScores[hole] = score;
    return copyWith(scores: newScores);
  }

  Player copyWith({
    String? name,
    String? avatar,
    int? handicap,
    String? colorHex,
    Map<int, int>? scores,
  }) {
    return Player(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      handicap: handicap ?? this.handicap,
      colorHex: colorHex ?? this.colorHex,
      scores: scores ?? this.scores,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatar': avatar,
      'handicap': handicap,
      'colorHex': colorHex,
      'scores': scores,
    };
  }

  static Player fromMap(Map<String, dynamic> map) {
    return Player(
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
      handicap: map['handicap'] ?? 0,
      colorHex: map['colorHex'] ?? '#FFFFFF',
      scores: Map<int, int>.from(map['scores'] ?? {}),
    );
  }
}
