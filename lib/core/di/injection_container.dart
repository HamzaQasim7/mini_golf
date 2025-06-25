// import 'package:get_it/get_it.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:mini_golf/core/database/hive_model.dart';
// import 'package:mini_golf/features/game/data/repositories/hive_course_repository.dart';
// import 'package:mini_golf/features/game/data/repositories/hive_game_repository.dart';
// import 'package:mini_golf/features/game/data/repositories/hive_player_repository.dart';
// import 'package:mini_golf/features/game/domain/repositories/course_repository.dart';
// import 'package:mini_golf/features/game/domain/repositories/game_repository.dart';
// import 'package:mini_golf/features/game/domain/repositories/player_repository.dart';
//
// final sl = GetIt.instance;
//
// Future<void> init() async {
//   // --- Hive Initialization ---
//   await Hive.initFlutter();
//
//   // Register all your Hive type adapters
//   Hive.registerAdapter(PlayerEntityAdapter());
//   Hive.registerAdapter(CourseEntityAdapter());
//   Hive.registerAdapter(HoleEntityAdapter());
//   Hive.registerAdapter(GameEntityAdapter());
//   Hive.registerAdapter(HoleScoreEntityAdapter());
//   Hive.registerAdapter(GameStatusAdapter());
//   Hive.registerAdapter(GameStatsEntityAdapter());
//
//   // Open Hive boxes
//   final playerBox = await Hive.openBox<PlayerEntity>('players');
//   final courseBox = await Hive.openBox<CourseEntity>('courses');
//   final gameBox = await Hive.openBox<GameEntity>('games');
//
//   sl.registerLazySingleton<Box<PlayerEntity>>(() => playerBox);
//   sl.registerLazySingleton<Box<CourseEntity>>(() => courseBox);
//   sl.registerLazySingleton<Box<GameEntity>>(() => gameBox);
//
//   // --- Repositories ---
//   sl.registerLazySingleton<PlayerRepository>(
//     () => HivePlayerRepository(
//       sl<Box<PlayerEntity>>(),
//     ),
//   );
//   sl.registerLazySingleton<CourseRepository>(
//     () => HiveCourseRepository(
//       sl<Box<CourseEntity>>(),
//     ),
//   );
//   sl.registerLazySingleton<GameRepository>(
//     () => HiveGameRepository(
//       sl<Box<GameEntity>>(),
//       sl<Box<PlayerEntity>>(),
//     ),
//   );
// }
