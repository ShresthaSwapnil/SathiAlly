import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:frontend/models/history_entry.dart';
import 'package:frontend/models/scenario.dart';
import 'package:frontend/models/score_response.dart';
import 'package:frontend/services/gamification_service.dart';
import 'package:frontend/features/dojo/session_complete_screen.dart';

class FeedbackScreen extends StatefulWidget {
  final Scenario scenario;
  final String userReply;
  final ScoreResponse feedback;

  const FeedbackScreen({
    super.key,
    required this.scenario,
    required this.userReply,
    required this.feedback,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveAndFinish(BuildContext context) async {
    final historyBox = Hive.box<HistoryEntry>('history');
    final totalScore = widget.feedback.scores.fold<int>(
      0,
      (sum, item) => sum + item.score,
    );
    final newEntry = HistoryEntry(
      scenarioContext: widget.scenario.context,
      hateSpeechComment: widget.scenario.hateSpeechComment,
      userReply: widget.userReply,
      suggestedRewrite: widget.feedback.suggestedRewrite,
      totalScore: totalScore,
      timestamp: DateTime.now(),
    );

    historyBox.add(newEntry);
    int xpGained = 5 + totalScore;
    await GamificationService().updateProgress(totalScore: totalScore);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SessionCompleteScreen(xpGained: xpGained),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalScore = widget.feedback.scores.fold<int>(
      0,
      (sum, item) => sum + item.score,
    );
    final maxScore = widget.feedback.scores.length * 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('After-Action AI Review'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // --- The Score Summary ---
          FadeInDown(
            child: _ScoreSummary(totalScore: totalScore, maxScore: maxScore),
          ),
          const SizedBox(height: 24),

          // --- The "You vs. AI" Comparison ---
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Your Reply'),
                    Tab(text: 'AI Suggestion'),
                  ],
                ),
                SizedBox(
                  height: 150, // Give the TabBarView a fixed height
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _ComparisonBox(text: widget.userReply),
                      _ComparisonBox(
                        text: widget.feedback.suggestedRewrite,
                        isSuggestion: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- The Detailed Breakdown ---
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Detailed Breakdown",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...widget.feedback.scores.map(
                  (score) => _ScoreBreakdownTile(score: score),
                ),
              ],
            ),
          ),
        ],
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
}

class _ScoreSummary extends StatelessWidget {
  final int totalScore;
  final int maxScore;
  const _ScoreSummary({required this.totalScore, required this.maxScore});

  @override
  Widget build(BuildContext context) {
    final double percentage = maxScore > 0 ? (totalScore / maxScore) : 0;
    return Center(
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: percentage,
              strokeWidth: 8,
              backgroundColor: Theme.of(context).colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$totalScore',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'out of $maxScore',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonBox extends StatelessWidget {
  final String text;
  final bool isSuggestion;
  const _ComparisonBox({required this.text, this.isSuggestion = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(
        side: isSuggestion
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              )
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}

class _ScoreBreakdownTile extends StatelessWidget {
  final Score score;
  const _ScoreBreakdownTile({required this.score});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  score.criterion,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${score.score}/3",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              score.rationale,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
