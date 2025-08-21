import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:frontend/screens/history_screen.dart';

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
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final user = leaderboard[index];
              final isCurrentUser = user['user_id'] == _currentUserId;
              return _RankTile(
                rank: index + 1,
                username: user['username'],
                xp: user['total_xp'],
                isCurrentUser: isCurrentUser,
              );
            },
          );
        },
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  final int rank;
  final String username;
  final int xp;
  final bool isCurrentUser;

  const _RankTile({
    required this.rank,
    required this.username,
    required this.xp,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.amber, Colors.grey[400], Colors.brown[300]];
    final Color? rankColor = rank <= 3 ? colors[rank - 1] : null;

    return Card(
      color: isCurrentUser
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : null,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrentUser
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              )
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              rank <= 3 ? Iconsax.crown_1 : Iconsax.user,
              color: rankColor ?? Theme.of(context).textTheme.bodySmall?.color,
            ),
            Text(
              '#$rank',
              style: TextStyle(fontWeight: FontWeight.bold, color: rankColor),
            ),
          ],
        ),
        title: Text(
          username,
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Text(
          '$xp XP',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
