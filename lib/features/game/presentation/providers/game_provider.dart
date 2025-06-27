// lib/features/game/presentation/providers/game_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/hive_model.dart';
import '../../../../core/services/hive_service.dart';

class GameProvider extends ChangeNotifier {
  Game? _currentGame;
  List<Game> _gameHistory = [];
  List<Course> _courses = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Game? get currentGame => _currentGame;
  List<Game> get gameHistory => _gameHistory;
  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveGame => _currentGame != null && !_currentGame!.isCompleted;

  final Uuid _uuid = const Uuid();

  GameProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadCourses();
    await _loadGameHistory();
    await _loadCurrentGame();
  }

  // Course Management
  Future<void> _loadCourses() async {
    try {
      _isLoading = true;
      notifyListeners();

      final courseBox = HiveService.courseBox;

      // Initialize default courses if empty
      if (courseBox.isEmpty) {
        await _initializeDefaultCourses();
      }

      _courses = courseBox.values.toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load courses: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _initializeDefaultCourses() async {
    final defaultCourses = [
      Course(
        id: _uuid.v4(),
        name: 'Blastzone Mini Golf',
        imageUrl: 'assets/images/mini-golf.jpg',
        holes: 18,
        parValues: [3, 2, 3, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2], // Pars from scorecard
      ),
      Course(
        id: _uuid.v4(),
        name: 'Crazy Mini Golf',
        imageUrl: 'assets/images/crazy_mini_golf.jpg',
        holes: 18,
        parValues: List.filled(18, 3),
      ),
    ];

    final courseBox = HiveService.courseBox;
    for (final course in defaultCourses) {
      await courseBox.add(course);
    }
  }

  // Game Management - Updated to work with the UI
  Future<void> createGame({
    required String courseName,
    required int numberOfHoles,
    required List<String> playerNames,
    required List<String> playerColors,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate input
      if (playerNames.length != playerColors.length) {
        throw Exception('Player names and colors count mismatch');
      }

      if (playerNames.length < 2) {
        throw Exception('At least 2 players required');
      }

      // Create players using Hive models
      final players = List.generate(playerNames.length, (index) {
        return Player(
          id: _uuid.v4(),
          name: playerNames[index],
          colorHex: playerColors[index],
          createdAt: DateTime.now(),
          handicap: 0, // Default handicap
        );
      });

      // Initialize hole scores
      final holes = List.generate(numberOfHoles, (holeIndex) {
        return List.generate(players.length, (playerIndex) {
          return HoleScore(strokes: 0, par: 3); // Default par 3
        });
      });

      // Create game
      final game = Game(
        id: _uuid.v4(),
        courseName: courseName,
        numberOfHoles: numberOfHoles,
        players: players,
        holes: holes,
        createdAt: DateTime.now(),
        currentHole: 1,
        isCompleted: false,
      );

      // Save to Hive
      final gameBox = HiveService.gameBox;
      await gameBox.add(game);

      // Save players
      final playerBox = HiveService.playerBox;
      for (final player in players) {
        await playerBox.add(player);
      }

      _currentGame = game;
      _gameHistory.insert(0, game);
      _error = null;
    } catch (e) {
      _error = 'Failed to create game: $e';
      debugPrint('Game creation error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Alternative method for creating game with domain entities (if needed)
  Future<void> createGameFromDomainEntities({
    required String courseName,
    required List<dynamic> domainPlayers, // Accept domain players
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Convert domain players to Hive models
      final players =
          domainPlayers.map((domainPlayer) {
            return Player(
              id: domainPlayer.id.isEmpty ? _uuid.v4() : domainPlayer.id,
              name: domainPlayer.name,
              colorHex: domainPlayer.colorHex,
              createdAt: domainPlayer.createdAt ?? DateTime.now(),
              handicap: domainPlayer.handicap ?? 0,
              avatar: domainPlayer.avatar,
            );
          }).toList();

      // Get course info
      final course = _courses.firstWhere(
        (c) => c.name == courseName,
        orElse:
            () => Course(
              id: _uuid.v4(),
              name: courseName,
              imageUrl: 'assets/images/default_course.jpg',
              holes: 18,
              parValues: List.filled(18, 3),
            ),
      );

      // Initialize hole scores
      final holes = List.generate(course.holes, (holeIndex) {
        return List.generate(players.length, (playerIndex) {
          final par =
              holeIndex < course.parValues.length
                  ? course.parValues[holeIndex]
                  : 3;
          return HoleScore(strokes: 0, par: par);
        });
      });

      // Create game
      final game = Game(
        id: _uuid.v4(),
        courseName: courseName,
        numberOfHoles: course.holes,
        players: players,
        holes: holes,
        createdAt: DateTime.now(),
        currentHole: 1,
        isCompleted: false,
      );

      // Save to Hive
      final gameBox = HiveService.gameBox;
      await gameBox.add(game);

      // Save players
      final playerBox = HiveService.playerBox;
      for (final player in players) {
        await playerBox.add(player);
      }

      _currentGame = game;
      _gameHistory.insert(0, game);
      _error = null;
    } catch (e) {
      _error = 'Failed to create game: $e';
      debugPrint('Game creation error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateHoleScore({
    required int holeIndex,
    required int playerIndex,
    required int strokes,
  }) async {
    if (_currentGame == null) return;

    try {
      _currentGame!.holes[holeIndex][playerIndex].strokes = strokes;
      await _currentGame!.save();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update score: $e';
      notifyListeners();
    }
  }

  Future<void> moveToNextHole() async {
    if (_currentGame == null) return;

    try {
      if (_currentGame!.currentHole < _currentGame!.numberOfHoles) {
        _currentGame!.currentHole++;
        await _currentGame!.save();
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to move to next hole: $e';
      notifyListeners();
    }
  }

  Future<void> moveToPreviousHole() async {
    if (_currentGame == null) return;

    try {
      if (_currentGame!.currentHole > 1) {
        _currentGame!.currentHole--;
        await _currentGame!.save();
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to move to previous hole: $e';
      notifyListeners();
    }
  }

  Future<void> completeGame() async {
    if (_currentGame == null) return;

    try {
      _currentGame!.isCompleted = true;
      _currentGame!.completedAt = DateTime.now();
      await _currentGame!.save();

      // Update game history
      final index = _gameHistory.indexWhere((g) => g.id == _currentGame!.id);
      if (index != -1) {
        _gameHistory[index] = _currentGame!;
      }

      _currentGame = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to complete game: $e';
      notifyListeners();
    }
  }

  Future<void> _loadGameHistory() async {
    try {
      final gameBox = HiveService.gameBox;
      _gameHistory =
          gameBox.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = 'Failed to load game history: $e';
    }
  }

  Future<void> _loadCurrentGame() async {
    try {
      final gameBox = HiveService.gameBox;
      final activeGames =
          gameBox.values.where((game) => !game.isCompleted).toList();
      _currentGame = activeGames.isNotEmpty ? activeGames.first : null;
    } catch (e) {
      _error = 'Failed to load current game: $e';
    }
  }

  Future<void> deleteGame(String gameId) async {
    try {
      final gameBox = HiveService.gameBox;
      final game = gameBox.values.firstWhere((g) => g.id == gameId);
      await game.delete();

      _gameHistory.removeWhere((g) => g.id == gameId);

      if (_currentGame?.id == gameId) {
        _currentGame = null;
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete game: $e';
      notifyListeners();
    }
  }

  // Utility methods
  List<int> getCurrentHoleScores() {
    if (_currentGame == null) return [];

    final holeIndex = _currentGame!.currentHole - 1;
    if (holeIndex < 0 || holeIndex >= _currentGame!.holes.length) return [];

    return _currentGame!.holes[holeIndex]
        .map((score) => score.strokes)
        .toList();
  }

  List<int> getTotalScores() {
    if (_currentGame == null) return [];
    return _currentGame!.getTotalScores();
  }

  Player? getWinner() {
    final winners = _currentGame?.getWinners();
    if (winners == null || winners.length != 1) return null;
    return winners.first;
  }

  bool canMoveToNextHole() {
    if (_currentGame == null) return false;

    final currentHoleScores = getCurrentHoleScores();
    return currentHoleScores.isNotEmpty &&
        currentHoleScores.every((score) => score > 0);
  }

  bool isLastHole() {
    if (_currentGame == null) return false;
    return _currentGame!.currentHole == _currentGame!.numberOfHoles;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _loadCourses();
    await _loadGameHistory();
    await _loadCurrentGame();
  }

  // Helper method to get current game info
  Map<String, dynamic>? getCurrentGameInfo() {
    if (_currentGame == null) return null;

    return {
      'courseName': _currentGame!.courseName,
      'currentHole': _currentGame!.currentHole,
      'totalHoles': _currentGame!.numberOfHoles,
      'players':
          _currentGame!.players
              .map(
                (p) => {
                  'name': p.name,
                  'color': p.colorHex,
                  'handicap': p.handicap,
                },
              )
              .toList(),
      'isCompleted': _currentGame!.isCompleted,
    };
  }

  // Helper method to get leaderboard
  List<Map<String, dynamic>> getLeaderboard() {
    if (_currentGame == null) return [];

    final totalScores = getTotalScores();
    final leaderboard = <Map<String, dynamic>>[];

    for (int i = 0; i < _currentGame!.players.length; i++) {
      leaderboard.add({
        'player': _currentGame!.players[i],
        'totalScore': totalScores[i],
      });
    }

    // Sort by score (ascending)
    leaderboard.sort((a, b) => a['totalScore'].compareTo(b['totalScore']));
    return leaderboard;
  }

  // Helper method to get the winner(s)
  List<Player> getWinners() {
    if (_currentGame == null || !_currentGame!.isCompleted) return [];

    final leaderboard = getLeaderboard();
    if (leaderboard.isEmpty) return [];

    final minScore = leaderboard.first['totalScore'];
    return leaderboard
        .where((entry) => entry['totalScore'] == minScore)
        .map((entry) => entry['player'] as Player)
        .toList();
  }
}

// Sort by score (ascending -
