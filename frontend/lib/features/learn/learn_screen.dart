import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/models/lesson.dart';
import 'package:frontend/models/quiz.dart';
import 'package:frontend/features/quiz/quiz_screen.dart';

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
  String? _currentTopic; // Variable to store the currently selected topic

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
        _currentTopic = topic; // Store the topic when the lesson is fetched
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load lesson. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // This method is no longer used since the button now launches the quiz,
  // but we can keep it for future reference or remove it. For now, it's commented out.
  /*
  void _markAsLearned() async {
    await GamificationService().updateProgress(totalScore: 10);
    setState(() {
      _currentLesson = null;
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
  */

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() => _error = null),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }
    if (_currentLesson != null && _currentTopic != null) {
      // Pass both the lesson and the topic to the build method
      return _buildLessonView(_currentLesson!, _currentTopic!);
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
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _fetchLesson(topic),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLessonView(Lesson lesson, String topic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A custom back button to return to the topic list
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.arrow_back_ios, size: 16),
              label: const Text("Back to Topics"),
              onPressed: () => setState(() {
                _currentLesson = null;
                _currentTopic = null;
              }),
            ),
          ),
          const SizedBox(height: 8),
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
          ElevatedButton.icon(
            icon: const Icon(Icons.quiz_outlined),
            onPressed: () async {
              setState(() => _isLoading = true);
              try {
                final questions = await _apiService.generateQuiz(topic: topic);
                if (mounted) {
                  // Push the QuizScreen onto the stack. When it pops, we'll be back here.
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(questions: questions),
                    ),
                  );
                  // After quiz is done, return to topic list
                  setState(() {
                    _currentLesson = null;
                    _currentTopic = null;
                  });
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not generate quiz. Please try again.',
                      ),
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
            label: const Text("Take the Quiz!"),
          ),
        ],
      ),
    );
  }
}
