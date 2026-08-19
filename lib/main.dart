import 'package:flutter/material.dart';

import 'src/arcade_ui.dart';
import 'src/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BricklyApp());
}

class BricklyApp extends StatelessWidget {
  const BricklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brickly Break by Stratida',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ArcadeColors.cyan,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          displayMedium: TextStyle(
            fontSize: 54,
            height: .98,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
          ),
          displaySmall: TextStyle(
            fontSize: 40,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            height: 1.12,
            fontWeight: FontWeight.w900,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            height: 1.2,
            fontWeight: FontWeight.w900,
          ),
          titleLarge: TextStyle(
            fontSize: 21,
            height: 1.25,
            fontWeight: FontWeight.w900,
            letterSpacing: .5,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            height: 1.3,
            fontWeight: FontWeight.w800,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.55,
            fontWeight: FontWeight.w500,
            color: ArcadeColors.muted,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            height: 1.5,
            fontWeight: FontWeight.w500,
            color: ArcadeColors.muted,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            height: 1.25,
            fontWeight: FontWeight.w900,
            letterSpacing: .4,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            height: 1.3,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            height: 1.3,
            fontWeight: FontWeight.w800,
            letterSpacing: .7,
          ),
        ),
      ),
      home: const BricklyHome(),
    );
  }
}
