import 'package:flutter/material.dart';

import 'home_screen.dart';

void main() => runApp(const DiseasePredictionApp());

class DiseasePredictionApp extends StatelessWidget {
  const DiseasePredictionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Care Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3424A1)),
      ),
      home: const HomeScreen(),
    );
  }
}
