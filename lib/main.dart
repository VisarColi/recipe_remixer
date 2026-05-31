import 'package:flutter/material.dart';
import 'screens/input_screen.dart';

void main() => runApp(const RecipeRemixerApp());

class RecipeRemixerApp extends StatelessWidget {
  const RecipeRemixerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Remixer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE65100)),
        useMaterial3: true,
      ),
      home: const InputScreen(),
    );
  }
}
