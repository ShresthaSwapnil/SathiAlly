import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/features/shell/main_screen.dart';
import 'dart:async';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _loadingMessage = "Initializing...";

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // This process now runs a series of tasks and provides feedback.
    final completer = Completer<void>();

    // Task 1: Start waking up the server and update the message.
    setState(() => _loadingMessage = "Waking up the AI coach...");
    // We don't await the ping here directly, but we handle its completion.
    ApiService()
        .pingServer()
        .then((_) {
          // This will run if the server responds successfully before the minimum wait time.
          setState(() => _loadingMessage = "Connecting...");
        })
        .catchError((_) {
          // This will run if the server ping times out or fails. It's okay.
          setState(() => _loadingMessage = "Coach is waking up, one moment...");
        });

    // Task 2: Ensure the splash screen is visible for a minimum duration for a premium feel.
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    // Wait for the minimum delay to finish.
    await completer.future;

    // Task 3: Navigate to the main app.
    if (mounted) {
      setState(() => _loadingMessage = "Ready!");
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use the theme's background color for a seamless look
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Fade in the logo, just like the Dojo screen
            FadeIn(
              duration: const Duration(milliseconds: 1000),
              child: Image.asset(
                'assets/logo.png', // Make sure this path is correct
                width: 120,
              ),
            ),
            const SizedBox(height: 24),
            // Fade in the tagline
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 500),
              child: Text(
                'Seeing the digital world clearly.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[500],
                ),
              ),
            ),
            const Spacer(),
            // Loading status indicator at the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(_loadingMessage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
