// lib/providers/game_provider.dart
import 'package:flutter/material.dart';
import '../../../../core/services/firebase_game_service.dart';
import '../../data/models/player_model.dart';

class GameProvider extends ChangeNotifier {
  final FirebaseGameService _gameService = FirebaseGameService();

  Game? _currentGame;
  bool _isLoading = false;
  String? _error;

  // Getters
  Game? get currentGame => _currentGame;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasGame => _currentGame != null;

  // Create a new game
  Future<void> createGame({
    required String courseName,
    required int numberOfHoles,
    required List<Player> players,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final game = Game(
        courseName: courseName.isEmpty ? 'Unnamed Course' : courseName,
        numberOfHoles: numberOfHoles,
        players: players,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      final gameId = await _gameService.createGame(game);
      _currentGame = game.copyWith(id: gameId);

      notifyListeners();
    } catch (e) {
      _setError('Failed to create game: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load existing game
  Future<void> loadGame(String gameId) async {
    try {
      _setLoading(true);
      _clearError();

      final game = await _gameService.getGame(gameId);
      _currentGame = game;

      notifyListeners();
    } catch (e) {
      _setError('Failed to load game: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add score for a player on current hole
  Future<void> addScore(String playerName, int hole, int score) async {
    if (_currentGame == null) return;

    try {
      _setLoading(true);
      _clearError();

      await _gameService.addScore(_currentGame!.id!, playerName, hole, score);

      // Update local state
      final updatedPlayers =
          _currentGame!.players.map((player) {
            if (player.name == playerName) {
              return player.addScore(hole, score);
            }
            return player;
          }).toList();

      _currentGame = _currentGame!.copyWith(
        players: updatedPlayers,
        lastUpdated: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to add score: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add scores for all players on a hole
  Future<void> addHoleScores(int hole, Map<String, int> playerScores) async {
    if (_currentGame == null) return;

    try {
      _setLoading(true);
      _clearError();

      // Add scores for each player
      for (final entry in playerScores.entries) {
        await _gameService.addScore(
          _currentGame!.id!,
          entry.key,
          hole,
          entry.value,
        );
      }

      // Update local state
      final updatedPlayers =
          _currentGame!.players.map((player) {
            final score = playerScores[player.name];
            if (score != null) {
              return player.addScore(hole, score);
            }
            return player;
          }).toList();

      _currentGame = _currentGame!.copyWith(
        players: updatedPlayers,
        lastUpdated: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to add hole scores: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Complete the game
  Future<void> completeGame() async {
    if (_currentGame == null) return;

    try {
      _setLoading(true);
      _clearError();

      await _gameService.completeGame(_currentGame!.id!);

      _currentGame = _currentGame!.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to complete game: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get current hole number
  int getCurrentHole() {
    if (_currentGame == null) return 1;

    // Find the next hole that needs scores
    for (int hole = 1; hole <= _currentGame!.numberOfHoles; hole++) {
      final hasAllScores = _currentGame!.players.every(
        (player) => player.getScoreForHole(hole) != null,
      );
      if (!hasAllScores) {
        return hole;
      }
    }

    return _currentGame!.numberOfHoles; // All holes completed
  }

  // Check if current hole is complete
  bool isHoleComplete(int hole) {
    if (_currentGame == null) return false;

    return _currentGame!.players.every(
      (player) => player.getScoreForHole(hole) != null,
    );
  }

  // Check if game is complete
  bool isGameComplete() {
    if (_currentGame == null) return false;
    return _currentGame!.isGameComplete;
  }

  // Get leaderboard
  List<MapEntry<Player, int>> getLeaderboard() {
    if (_currentGame == null) return [];
    return _currentGame!.getLeaderboard();
  }

  // Get winners
  List<Player> getWinners() {
    if (_currentGame == null) return [];
    return _currentGame!.getWinners();
  }

  // Reset game state
  void resetGame() {
    _currentGame = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Stream game updates
  Stream<Game?> streamGame(String gameId) {
    return _gameService.streamGame(gameId);
  }
}
