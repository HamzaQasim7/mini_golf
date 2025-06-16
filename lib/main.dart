import 'package:flutter/material.dart';

import 'core/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  // await di.init();

  runApp(const App());
}
