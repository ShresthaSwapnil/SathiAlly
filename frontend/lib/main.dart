import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/screens/home_screen.dart';

Future<void> main() async {
  // Load the environment variables from the .env file
  await dotenv.load(fileName: ".env");
  runApp(const SathiAllyApp());
}

class SathiAllyApp extends StatelessWidget {
  const SathiAllyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sathi Ally',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark, // Use a dark theme as a base
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
