import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/models/player_progress.dart';
import 'package:frontend/models/scenario.dart';
import 'package:frontend/screens/history_screen.dart';
import 'package:frontend/screens/scenario_screen.dart';
import 'package:frontend/services/gamification_service.dart';

class DojoScreen extends StatefulWidget {
  const DojoScreen({super.key});

  @override
  State<DojoScreen> createState() => _DojoScreenState();
}

class _DojoScreenState extends State<DojoScreen> {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  final GamificationService _gamificationService = GamificationService();
  late PlayerProgress _playerProgress;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    setState(() {
      _playerProgress = _gamificationService.getProgress();
    });
  }

  // CORRECTED METHOD DEFINITION: topic is an optional named parameter.
  void _startNewSession({String? topic}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // The `topic` parameter is passed directly to the ApiService.
      // If it's null, a random scenario is generated. If it has a value, a themed one is.
      final Scenario scenario = await _apiService.generateScenario(
        topic: topic,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScenarioScreen(scenario: scenario),
          ),
        );
        _loadProgress();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showTopicSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final topics = [
          "Online Gaming",
          "Political Discussion",
          "Sports Debate",
          "Social Media Comments",
          "Workplace Chat",
        ];
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Choose a Scenario Topic",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...topics
                  .map(
                    (topic) => ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // CORRECTED CALL: We pass the selected topic from the map.
                        _startNewSession(topic: topic);
                      },
                      child: Text(topic),
                    ),
                  )
                  .expand((widget) => [widget, const SizedBox(height: 8)]),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Sathi Ally'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.history),
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => const HistoryScreen()),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatsBar(), // <-- Our new stats bar
                    const Spacer(),
                    FadeInDown(child: const Icon(Icons.security, size: 80)),
                    const SizedBox(height: 20),
                    FadeInUp(
                      child: Text(
                        'Welcome to your Dialogue Dojo',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 200),
                      child: const Text(
                        'Practice responding to tough online conversations in a safe space.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 400),
                      child: ElevatedButton.icon(
                        // CORRECTED CALL: Calling with no arguments is valid for an optional parameter.
                        onPressed: () =>
                            _startNewSession(), // Start with a random topic
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Random Session'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 500),
                      child: OutlinedButton(
                        onPressed: _showTopicSelection,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Choose a Topic...'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            Icons.star,
            '${_playerProgress.totalXp} XP',
            Colors.amber,
          ),
          _buildStatItem(
            Icons.local_fire_department,
            '${_playerProgress.streakCount} Day Streak',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
