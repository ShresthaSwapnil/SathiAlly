import 'package:flutter/material.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:frontend/screens/history_screen.dart'; // Import history screen

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ApiService _apiService = ApiService();
  final String _currentUserId = ProfileService().getUserId();
  late Future<List<dynamic>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _apiService.getLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryScreen()),
        ),
        label: const Text('My Session History'),
        icon: const Icon(Icons.history),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load leaderboard: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Be the first on the leaderboard!'),
            );
          }

          final leaderboard = snapshot.data!;
          return ListView.builder(
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final user = leaderboard[index];
              final isCurrentUser = user['user_id'] == _currentUserId;
              return Card(
                color: isCurrentUser
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : null,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  title: Text(
                    user['username'],
                    style: TextStyle(
                      fontWeight: isCurrentUser
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: Text(
                    '${user['total_xp']} XP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
