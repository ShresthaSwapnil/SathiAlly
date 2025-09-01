import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:frontend/models/history_entry.dart';
import 'package:frontend/models/player_progress.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:frontend/features/shell/loading_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();

  Hive.registerAdapter(HistoryEntryAdapter());
  Hive.registerAdapter(PlayerProgressAdapter());

  await Hive.openBox<HistoryEntry>('history');
  await Hive.openBox<PlayerProgress>('player_progress');
  await Hive.openBox('profile');

  await Hive.openBox<String>('completed_lessons');
  await Hive.openBox('dojo_progress');

  await ProfileService().initProfile();

  runApp(const SathiAllyApp());
}

class SathiAllyApp extends StatelessWidget {
  const SathiAllyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- 1. Define a modern, LIGHT theme ---
    final lightTheme = ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Off-white background
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6200EE), // A vibrant purple for primary actions
        secondary: Color(0xFF03DAC6), // A teal for accents
        surface: Colors.white, // Card backgrounds
        onPrimary: Colors.white, // Text on primary color
        onSecondary: Colors.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black, // Makes app bar text and icons black
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6200EE),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );

    // --- 2. Define a modern, DARK theme ---
    final darkTheme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFBB86FC), // A lighter purple for dark mode
        secondary: Color(0xFF03DAC6),
        surface: Color(0xFF1E1E1E),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFBB86FC),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );

    return MaterialApp(
      title: 'Netra',
      debugShowCheckedModeBanner: false,

      // --- 3. Set the themes and theme mode ---
      theme: lightTheme, // The default theme for the app.
      darkTheme: darkTheme, // The theme to use when the device is in dark mode.
      themeMode: ThemeMode
          .system, // This is the magic part! It tells Flutter to follow the device's setting.

      home: const LoadingScreen(),
    );
  }
}
