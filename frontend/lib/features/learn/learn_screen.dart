import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/models/lesson.dart';
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
  String? _currentTopic;

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_currentLesson != null) {
      return _buildLessonView(_currentLesson!, _currentTopic!);
    }
    return _buildTopicSelectionView();
  }

  Widget _buildTopicSelectionView() {
    final topicData = [
      {'icon': Iconsax.message_question, 'color': Colors.blue},
      {'icon': Iconsax.eye, 'color': Colors.red},
      {'icon': Iconsax.cpu_setting, 'color': Colors.purple},
      {'icon': Iconsax.shield_tick, 'color': Colors.green},
      {'icon': Iconsax.bubble, 'color': Colors.orange},
      {'icon': Iconsax.document_text, 'color': Colors.teal},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What do you want to learn today?",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _topics.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0, // Makes the cards square
            ),
            itemBuilder: (context, index) {
              return FadeInUp(
                delay: Duration(milliseconds: 100 * index),
                child: _TopicCard(
                  title: _topics[index],
                  icon: topicData[index]['icon'] as IconData,
                  color: topicData[index]['color'] as Color,
                  onTap: () => _fetchLesson(_topics[index]),
                ),
              );
            },
          ),
        ],
      ),
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

class _TopicCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TopicCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // We are changing the Column's alignment properties
          child: Column(
            // --- CHANGE 1: Center vertically ---
            mainAxisAlignment: MainAxisAlignment.center,
            // --- CHANGE 2: Center horizontally ---
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color), // Made the icon a bit bigger
              const SizedBox(height: 12), // Added a bit of space
              Text(
                title,
                textAlign: TextAlign
                    .center, // --- CHANGE 3: Center the text itself ---
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
