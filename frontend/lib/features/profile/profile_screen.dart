import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:frontend/models/player_progress.dart';
import 'package:frontend/screens/history_screen.dart';
import 'package:frontend/services/gamification_service.dart';
import 'package:frontend/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final GamificationService _gamificationService = GamificationService();

  late String _username;
  late PlayerProgress _playerProgress;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    setState(() {
      _username = _profileService.getUsername();
      _playerProgress = _gamificationService.getProgress();
    });
  }

  void _changeUsername() async {
    HapticFeedback.mediumImpact();
    final newName = await _profileService.regenerateUsername();
    setState(() {
      _username = newName;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your new anonymous name is $newName!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // A simple leveling system: every 100 XP is a new level.
    final int currentLevel = (_playerProgress.totalXp / 100).floor();
    final int xpForNextLevel = ((currentLevel + 1) * 100);
    final double xpProgress = (_playerProgress.totalXp % 100) / 100.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop();
          },
        ),
        title: const Text('My Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        children: [
          const SizedBox(height: 20),
          // --- The New "Hero" Section ---
          FadeInDown(
            child: _ProfileHeader(
              username: _username,
              currentLevel: currentLevel,
              xpProgress: xpProgress,
              xpForNextLevel: xpForNextLevel,
              totalXp: _playerProgress.totalXp,
            ),
          ),
          const SizedBox(height: 32),

          // --- The Stats Section ---
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _StatsGrid(playerProgress: _playerProgress),
          ),
          const SizedBox(height: 32),

          // --- The Actions Section ---
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Actions', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Iconsax.document_text_1,
                  title: 'View My Session History',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Iconsax.refresh,
                  title: 'Get a New Anonymous Name',
                  onTap: _changeUsername,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Add the disclaimer text back at the bottom of the ListView
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: const Text(
              'Your user ID and name are generated randomly on your device to keep you anonymous on the public leaderboard.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// --- NEW CUSTOM WIDGETS for a clean, modular build method ---

class _ProfileHeader extends StatelessWidget {
  final String username;
  final int currentLevel, totalXp, xpForNextLevel;
  final double xpProgress;

  const _ProfileHeader({
    required this.username,
    required this.currentLevel,
    required this.xpProgress,
    required this.xpForNextLevel,
    required this.totalXp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Iconsax.user_octagon,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Level $currentLevel',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        // XP Progress Bar
        LinearProgressIndicator(
          value: xpProgress,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$totalXp XP', style: Theme.of(context).textTheme.bodySmall),
            Text(
              '$xpForNextLevel XP to next level',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final PlayerProgress playerProgress;
  const _StatsGrid({required this.playerProgress});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              context,
              Iconsax.star_1,
              '${playerProgress.totalXp} XP',
              'Total Experience',
            ),
            const SizedBox(height: 75, child: VerticalDivider()),
            _buildStatItem(
              context,
              Icons.local_fire_department,
              '${playerProgress.streakCount} Day Streak',
              'Current Streak',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Iconsax.arrow_right_3, size: 20),
      ),
    );
  }
}
