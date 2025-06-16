import 'package:flutter/material.dart';
import 'package:mini_golf/core/routes/routes_name.dart';
import 'package:mini_golf/features/game/presentation/pages/add_player_screen.dart';
import 'package:mini_golf/features/game/presentation/pages/hole_score_screen.dart';
import 'package:mini_golf/features/home/presentation/pages/home_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      // case RouteNames.transactions:
      //   return MaterialPageRoute(
      //     builder: (_) => const TransactionHistoryPage(),
      //   );
      //
      // // Profile Routes
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case RouteNames.addPlayer:
        return MaterialPageRoute(builder: (_) => const AddPlayersScreen());

      // Default - Page Not Found
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
