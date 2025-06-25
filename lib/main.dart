import 'package:flutter/material.dart';
import 'package:mini_golf/core/di/injection_container.dart' as di;
import 'package:mini_golf/features/game/presentation/providers/game_provider.dart';
import 'package:provider/provider.dart';

import 'core/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize dependencies
  await di.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GameProvider(
            gameRepository: di.sl(),
            playerRepository: di.sl(),
            courseRepository: di.sl(),
          ),
        ),
      ],
      child: const App(),
    ),
  );
}
