import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';

void main() {
  runApp(const AdvancedAnimationsApp());
}

class AdvancedAnimationsApp extends StatelessWidget {
  const AdvancedAnimationsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Animations Lab',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.purpleAccent,
          surface: Color(0xFF0F172A),
        ),
        scaffoldBackgroundColor: const Color(0xFF050B14),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'sans-serif'),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: false),
      ),
      home: const DashboardScreen(),
    );
  }
}
