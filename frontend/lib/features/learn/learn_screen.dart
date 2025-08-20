import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/models/lesson.dart';
import 'package:frontend/services/gamification_service.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final ApiService _apiService = ApiService();
  Lesson? _currentLesson;
  bool _isLoading = false;
  String? _error;

  final List<String> _topics = [
    "What is Misinformation?",
    "How to Spot a Deepfake",
    "Understanding Algorithmic Bias",
    "Identifying Phishing Scams",
    "The Echo Chamber Effect",
    "Fact-Checking 101",
  ];

  void _fetchLesson(String topic) async {
    setState(() {
      _isLoading = true;
      _currentLesson = null;
      _error = null;
    });
    try {
      final lesson = await _apiService.generateLesson(topic: topic);
      setState(() {
        _currentLesson = lesson;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load lesson. Please try again.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _markAsLearned() async {
    // Award 10 XP for completing a lesson
    await GamificationService().updateProgress(totalScore: 10);
    setState(() {
      _currentLesson = null; // Go back to the topics list
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('+10 XP! Your knowledge is growing.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_currentLesson != null) {
      return _buildLessonView(_currentLesson!);
    }
    return _buildTopicSelectionView();
  }

  Widget _buildTopicSelectionView() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          "What do you want to learn today?",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._topics.asMap().entries.map((entry) {
          int idx = entry.key;
          String topic = entry.value;
          return FadeInUp(
            delay: Duration(milliseconds: 100 * idx),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(topic),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _fetchLesson(topic),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLessonView(Lesson lesson) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _currentLesson = null),
            alignment: Alignment.centerLeft,
          ),
          Text(
            lesson.title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ...lesson.content.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                paragraph,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Real-World Example",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lesson.example,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _markAsLearned,
            child: const Text("I've Learned This! (+10 XP)"),
          ),
        ],
      ),
    );
  }
}
