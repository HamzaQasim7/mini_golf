// lib/services/firebase_game_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/game/data/models/player_model.dart';

class FirebaseGameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _gamesCollection = 'games';

  // Create a new game
  Future<String> createGame(Game game) async {
    try {
      final docRef = await _firestore
          .collection(_gamesCollection)
          .add(game.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create game: $e');
    }
  }

  // Get a game by ID
  Future<Game?> getGame(String gameId) async {
    try {
      final doc =
          await _firestore.collection(_gamesCollection).doc(gameId).get();
      if (doc.exists) {
        return Game.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get game: $e');
    }
  }

  // Update game
  Future<void> updateGame(String gameId, Game game) async {
    try {
      await _firestore
          .collection(_gamesCollection)
          .doc(gameId)
          .update(game.toMap());
    } catch (e) {
      throw Exception('Failed to update game: $e');
    }
  }

  // Add score for a player on a specific hole
  Future<void> addScore(
    String gameId,
    String playerName,
    int hole,
    int score,
  ) async {
    try {
      final gameDoc = _firestore.collection(_gamesCollection).doc(gameId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(gameDoc);
        if (!snapshot.exists) {
          throw Exception('Game does not exist');
        }

        final game = Game.fromMap(snapshot.data()!, snapshot.id);

        // Find the player and update their score
        final updatedPlayers =
            game.players.map((player) {
              if (player.name == playerName) {
                final updatedScores = Map<int, int>.from(player.scores);
                updatedScores[hole] = score;
                return player.copyWith(scores: updatedScores);
              }
              return player;
            }).toList();

        final updatedGame = game.copyWith(
          players: updatedPlayers,
          lastUpdated: DateTime.now(),
        );

        transaction.update(gameDoc, updatedGame.toMap());
      });
    } catch (e) {
      throw Exception('Failed to add score: $e');
    }
  }

  // Complete the game
  Future<void> completeGame(String gameId) async {
    try {
      await _firestore.collection(_gamesCollection).doc(gameId).update({
        'isCompleted': true,
        'completedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to complete game: $e');
    }
  }

  // Get all games (for history)
  Future<List<Game>> getAllGames() async {
    try {
      final snapshot =
          await _firestore
              .collection(_gamesCollection)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => Game.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get games: $e');
    }
  }

  // Delete a game
  Future<void> deleteGame(String gameId) async {
    try {
      await _firestore.collection(_gamesCollection).doc(gameId).delete();
    } catch (e) {
      throw Exception('Failed to delete game: $e');
    }
  }

  // Stream game updates
  Stream<Game?> streamGame(String gameId) {
    return _firestore.collection(_gamesCollection).doc(gameId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return Game.fromMap(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }
}
