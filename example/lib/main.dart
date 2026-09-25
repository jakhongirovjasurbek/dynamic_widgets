import 'package:flutter/material.dart';

import 'builder/builder_page.dart';
import 'builder/console.dart';

void main() {
  // Layout errors from the JSON tree (e.g. Positioned outside Stack) go to the console.
  ConsoleLog.instance.captureFlutterErrors();
  runApp(const BuilderApp());
}

/// Example app: a visual builder for `dynamic_widgets` JSON.
///
/// Run with `flutter run -d chrome` or `flutter run -d macos`.
class BuilderApp extends StatelessWidget {
  const BuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Widgets Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF0053CE), brightness: Brightness.light),
      darkTheme: ThemeData(colorSchemeSeed: const Color(0xFF0053CE), brightness: Brightness.dark),
      home: const BuilderPage(),
    );
  }
}
