import 'package:flutter/material.dart';
import 'package:mini_golf/core/services/hive_service.dart';
import 'package:mini_golf/features/game/presentation/providers/game_provider.dart';
import 'package:mini_golf/features/game/presentation/providers/player_provider.dart';
import 'package:provider/provider.dart';

import 'core/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => PlayerSetupProvider()),
      ],
      child: const App(),
    ),
  );
}
