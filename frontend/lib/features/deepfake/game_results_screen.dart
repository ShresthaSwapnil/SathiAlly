import 'package:flutter/material.dart';
import 'package:frontend/services/gamification_service.dart';

class GameResultsScreen extends StatelessWidget {
  final int score;
  final int totalRounds;
  const GameResultsScreen({
    super.key,
    required this.score,
    required this.totalRounds,
  });

  void _finishAndClaimXP(BuildContext context) async {
    // Award 4 XP per correct answer in the game
    int xpGained = score * 4;
    await GamificationService().updateProgress(totalScore: xpGained);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+$xpGained XP! Sharp eyes!'),
          backgroundColor: Colors.green,
        ),
      );
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
              'Game Over!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('You correctly identified', style: TextStyle(fontSize: 20)),
            Text(
              '$score / $totalRounds',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _finishAndClaimXP(context),
              child: const Text('Claim Reward'),
            ),
          ],
        ),
      ),
    );
  }
}
