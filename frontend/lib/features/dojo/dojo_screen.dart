import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/models/player_progress.dart';
import 'package:frontend/models/scenario.dart';
import 'package:frontend/screens/scenario_screen.dart';
import 'package:frontend/services/gamification_service.dart';
import 'package:frontend/services/dojo_progress_service.dart';
import 'package:flutter/services.dart';

class DojoScreen extends StatefulWidget {
  const DojoScreen({super.key});

  @override
  State<DojoScreen> createState() => _DojoScreenState();
}

class _DojoScreenState extends State<DojoScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  final GamificationService _gamificationService = GamificationService();
  late PlayerProgress _playerProgress;

  late AnimationController _animationController;

  final DojoProgressService _dojoProgressService = DojoProgressService();
  late int _sessionsToday;

  @override
  void initState() {
    super.initState();
    _loadProgress();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadProgress() {
    setState(() {
      _playerProgress = _gamificationService.getProgress();
      _sessionsToday = _dojoProgressService.getSessionsCompletedToday();
    });
  }

  // CORRECTED METHOD DEFINITION: topic is an optional named parameter.
  void _startNewSession({String? topic}) async {
    HapticFeedback.mediumImpact();
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
    HapticFeedback.lightImpact();
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
                children: [
                  const SizedBox(height: 16),
                  FadeIn(child: _StatsHeader(playerProgress: _playerProgress)),
                  const SizedBox(height: 24),
                  // --- NEW: Daily Goal Card ---
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _DailyGoalCard(sessionsToday: _sessionsToday),
                  ),

                  // The new Hero Action Card takes center stage
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: _HeroActionCard(
                            animationController: _animationController,
                            onTap: () => _startNewSession(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // The secondary action is now less prominent and at the bottom
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: TextButton(
                        onPressed: _showTopicSelection,
                        child: const Text('Or choose a specific topic...'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
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
              Icons.local_fire_department_outlined,
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

class _HeroActionCard extends StatelessWidget {
  final AnimationController animationController;
  final VoidCallback onTap;
  const _HeroActionCard({
    required this.animationController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Enter the Dojo',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Tap below to start a new training simulation.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FadeTransition(
          opacity: Tween<double>(
            begin: 0.7,
            end: 1.0,
          ).animate(animationController),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(
              CurvedAnimation(
                parent: animationController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Card(
              elevation: 8,
              shadowColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.4),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Icon(
                    Iconsax.security_safe,
                    size: 70,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  final int sessionsToday;
  final int goal = 1; // Our simple daily goal is 1 session
  const _DailyGoalCard({required this.sessionsToday});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = sessionsToday >= goal;
    return Card(
      color: isCompleted ? Colors.green.withOpacity(0.2) : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isCompleted ? Iconsax.tick_circle : Iconsax.clock,
              color: isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Goal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isCompleted
                        ? 'Great work today!'
                        : 'Complete a Dojo session to maintain your streak.',
                  ),
                ],
              ),
            ),
            Text(
              '$sessionsToday / $goal',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
