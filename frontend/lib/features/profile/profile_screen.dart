import 'package:flutter/material.dart';
import 'package:frontend/models/player_progress.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // --- Profile Header ---
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _username,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Anonymous User',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            // --- Stats Section ---
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              ),
            ),
            const SizedBox(height: 40),
            // --- Actions Section ---
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              onPressed: _changeUsername,
              label: const Text('Get a New Name'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your user ID and name are generated randomly on your device to keep you anonymous on the leaderboard.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
