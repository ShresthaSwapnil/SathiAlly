import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:frontend/models/history_entry.dart';
import 'package:frontend/models/scenario.dart';
import 'package:frontend/models/score_response.dart';
import 'package:frontend/services/gamification_service.dart';

class FeedbackScreen extends StatelessWidget {
  final Scenario scenario;
  final String userReply;
  final ScoreResponse feedback;

  const FeedbackScreen({
    super.key,
    required this.scenario,
    required this.userReply,
    required this.feedback,
  });

  void _saveAndFinish(BuildContext context) async {
    final historyBox = Hive.box<HistoryEntry>('history');
    final totalScore = feedback.scores.fold<int>(
      0,
      (sum, item) => sum + item.score,
    );

    final newEntry = HistoryEntry(
      scenarioContext: scenario.context,
      hateSpeechComment: scenario.hateSpeechComment,
      userReply: userReply,
      suggestedRewrite: feedback.suggestedRewrite,
      totalScore: totalScore,
      timestamp: DateTime.now(),
    );

    historyBox.add(newEntry);

    // Update the user's XP and Streak
    await GamificationService().updateProgress(totalScore: totalScore);

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach Feedback'),
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildComparisonCard("Your Reply", userReply, Colors.blueGrey),
            const SizedBox(height: 16),
            _buildComparisonCard(
              "Suggested Rewrite",
              feedback.suggestedRewrite,
              Colors.deepPurple,
            ),
            const SizedBox(height: 24),
            Text(
              "Feedback Breakdown",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ...feedback.scores.map((score) => _buildScoreTile(score)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _saveAndFinish(context),
          child: const Text('Finish & Save Session'),
        ),
      ),
    );
  }

  Widget _buildComparisonCard(String title, String text, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreTile(Score score) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  score.criterion,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Score: ${score.score}/3",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(score.rationale, style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
