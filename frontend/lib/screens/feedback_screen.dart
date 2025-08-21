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
    // ... (This logic is unchanged)
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
    await GamificationService().updateProgress(totalScore: totalScore);
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach Feedback'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Use colors from the theme's colorScheme
            _buildComparisonCard(
              context,
              "Your Reply",
              userReply,
              Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            _buildComparisonCard(
              context,
              "Suggested Rewrite",
              feedback.suggestedRewrite,
              Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              "Feedback Breakdown",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Pass context to the score tile to access the theme
            ...feedback.scores
                .map((score) => _buildScoreTile(context, score))
                .toList(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _saveAndFinish(context),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Text('Finish & Save Session'),
        ),
      ),
    );
  }

  // Pass BuildContext to access the theme
  Widget _buildComparisonCard(
    BuildContext context,
    String title,
    String text,
    Color color,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  // Pass BuildContext to access the theme
  Widget _buildScoreTile(BuildContext context, Score score) {
    // Use the theme's text color for subtitles
    final subtitleColor = Theme.of(
      context,
    ).textTheme.bodySmall?.color?.withOpacity(0.7);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    score.criterion,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "${score.score}/3",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(score.rationale, style: TextStyle(color: subtitleColor)),
          ],
        ),
      ),
    );
  }
}
