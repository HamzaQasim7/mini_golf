import 'package:flutter/material.dart';
import 'package:mini_golf/core/routes/app_routes.dart';
import 'package:mini_golf/features/home/presentation/pages/home_page.dart';

import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Golf',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      onGenerateRoute: AppRouter.generateRoute,
      home: HomePage(),
      // initialRoute: RouteNames.bottomNav,
      debugShowCheckedModeBanner: false,
    );
  }
}
