import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:frontend/services/gamification_service.dart';
import 'package:frontend/services/learn_progress_service.dart';

class QuizResultsScreen extends StatelessWidget {
  final String topic;
  final int score;
  final int totalQuestions;
  const QuizResultsScreen({
    super.key,
    required this.topic,
    required this.score,
    required this.totalQuestions,
  });

  void _finishAndClaimXP(BuildContext context) async {
    int xpGained = score * 5;
    await GamificationService().updateProgress(totalScore: xpGained);
    if ((score / totalQuestions) >= 0.5) {
      await LearnProgressService().completeLesson(topic);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+$xpGained XP! Well done!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    double percentage = totalQuestions > 0 ? (score / totalQuestions) : 0;
    String message = percentage >= 0.8
        ? "Excellent Work!"
        : percentage >= 0.5
        ? "Good Job!"
        : "Keep Practicing!";

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeInDown(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeIn(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'You scored',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 8),
              FadeIn(
                delay: const Duration(milliseconds: 500),
                child: Text(
                  '$score / $totalQuestions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: ElevatedButton(
                  onPressed: () => _finishAndClaimXP(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text('Finish and Claim Reward'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
