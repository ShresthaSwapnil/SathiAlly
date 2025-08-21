import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/models/player_progress.dart';
import 'package:frontend/models/scenario.dart';
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // New, improved stats header
                  FadeIn(
                    duration: const Duration(milliseconds: 500),
                    child: _StatsHeader(playerProgress: _playerProgress),
                  ),
                  const Spacer(),
                  // Main content with better hierarchy
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      'Ready for a Challenge?',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 200),
                    child: const Text(
                      'Practice makes perfect. Jump into a scenario to sharpen your skills.',
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 400),
                    child: ElevatedButton.icon(
                      onPressed: () => _startNewSession(),
                      icon: const Icon(Iconsax.play),
                      label: const Text('Start Random Session'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 500),
                    child: OutlinedButton(
                      onPressed: _showTopicSelection,
                      child: const Text('Choose a Specific Topic'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
    );
  }

  // Widget _buildStatsBar() {
  //   return FadeIn(
  //     duration: const Duration(milliseconds: 500),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //       children: [
  //         _buildStatItem(
  //           Icons.star,
  //           '${_playerProgress.totalXp} XP',
  //           Colors.amber,
  //         ),
  //         _buildStatItem(
  //           Icons.local_fire_department,
  //           '${_playerProgress.streakCount} Day Streak',
  //           Colors.orange,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStatItem(IconData icon, String label, Color color) {
  //   return Row(
  //     children: [
  //       Icon(icon, color: color, size: 28),
  //       const SizedBox(width: 8),
  //       Text(
  //         label,
  //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //     ],
  //   );
  // }
}

class _StatsHeader extends StatelessWidget {
  final PlayerProgress playerProgress;
  const _StatsHeader({required this.playerProgress});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              context,
              Iconsax.star_1,
              '${playerProgress.totalXp} XP',
              Colors.amber,
            ),
            const SizedBox(height: 30, child: VerticalDivider()),
            _buildStatItem(
              context,
              Icons.local_fire_department,
              '${playerProgress.streakCount} Day Streak',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
