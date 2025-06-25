// lib/core/database/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../database/hive_model.dart';

part 'hive_model.g.dart';

class HiveService {
  static const String _gameBoxName = 'games';
  static const String _playerBoxName = 'players';
  static const String _courseBoxName = 'courses';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters only if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GameAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PlayerAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CourseAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(HoleScoreAdapter());
    }

    // Open boxes
    await Hive.openBox<Game>(_gameBoxName);
    await Hive.openBox<Player>(_playerBoxName);
    await Hive.openBox<Course>(_courseBoxName);
  }

  static Box<Game> get gameBox => Hive.box<Game>(_gameBoxName);
  static Box<Player> get playerBox => Hive.box<Player>(_playerBoxName);
  static Box<Course> get courseBox => Hive.box<Course>(_courseBoxName);

  static Future<void> dispose() async {
    await Hive.close();
  }
}
