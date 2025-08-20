import 'package:flutter/material.dart';
import 'package:frontend/services/gamification_service.dart';

class QuizResultsScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const QuizResultsScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  void _finishAndClaimXP(BuildContext context) async {
    // Award 5 XP per correct answer
    int xpGained = score * 5;
    await GamificationService().updateProgress(totalScore: xpGained);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+$xpGained XP! Well done!'),
          backgroundColor: Colors.green,
        ),
      );
      // Pop twice: once to get off the results screen, once to get off the (now replaced) quiz screen.
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Quiz Complete!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('You scored', style: TextStyle(fontSize: 20)),
            Text(
              '$score / $totalQuestions',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _finishAndClaimXP(context),
              child: const Text('Awesome!'),
            ),
          ],
        ),
      ),
    );
  }
}
