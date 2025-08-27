import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/services/profile_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ApiService _apiService = ApiService();
  final String _currentUserId = ProfileService().getUserId();
  final String _currentUsername = ProfileService().getUsername();
  late Future<List<dynamic>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _apiService.getLeaderboard();
  }

  void _refreshLeaderboard() {
    setState(() {
      _leaderboardFuture = _apiService.getLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _refreshLeaderboard(),
        child: FutureBuilder<List<dynamic>>(
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
            final topThree = leaderboard.take(3).toList();
            final rest = leaderboard.skip(3).toList();

            // Find the current user's rank and data
            final currentUserRank = leaderboard.indexWhere(
              (user) => user['user_id'] == _currentUserId,
            );
            final currentUserData = currentUserRank != -1
                ? leaderboard[currentUserRank]
                : null;

            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.only(
                    bottom: 90,
                  ), // Space for the persistent banner
                  children: [
                    // --- THE PODIUM ---
                    if (topThree.isNotEmpty)
                      _Podium(
                        topThree: topThree,
                        currentUserId: _currentUserId,
                      ),

                    // --- THE REST OF THE LIST ---
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'Top 50',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ...rest.asMap().entries.map((entry) {
                      final index = entry.key + 4; // Start rank from 4
                      final user = entry.value;
                      return _RankTile(
                        rank: index,
                        username: user['username'],
                        xp: user['total_xp'],
                        isCurrentUser: user['user_id'] == _currentUserId,
                      );
                    }),
                  ],
                ),
                // --- PERSISTENT USER RANK BANNER ---
                if (currentUserData != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _UserRankBanner(
                      rank: currentUserRank + 1,
                      username: _currentUsername,
                      xp: currentUserData['total_xp'],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// --- NEW WIDGET: The Podium for Top 3 ---
class _Podium extends StatelessWidget {
  final List<dynamic> topThree;
  final String currentUserId;
  const _Podium({required this.topThree, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    // Reorder to show 2nd, 1st, 3rd for the classic podium look
    final podiumOrder = [
      if (topThree.length > 1) topThree[1],
      topThree[0],
      if (topThree.length > 2) topThree[2],
    ];
    final podiumHeights = [100.0, 140.0, 80.0];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(podiumOrder.length, (index) {
          final user = podiumOrder[index];
          final rank = topThree.indexOf(user) + 1;
          return _PodiumPlace(
            rank: rank,
            height: podiumHeights[index],
            username: user['username'],
            xp: user['total_xp'],
            isCurrentUser: user['user_id'] == currentUserId,
          );
        }),
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  // ... (Constructor for rank, height, username, xp, isCurrentUser)
  final int rank;
  final double height;
  final String username;
  final int xp;
  final bool isCurrentUser;

  const _PodiumPlace({
    required this.rank,
    required this.height,
    required this.username,
    required this.xp,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.amber, Colors.grey[400]!, Colors.brown[300]!];
    return FadeInUp(
      delay: Duration(milliseconds: 200 * rank),
      child: Column(
        children: [
          Text(
            username,
            style: TextStyle(
              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Icon(Iconsax.crown_1, color: colors[rank - 1], size: 28),
          const SizedBox(height: 4),
          Container(
            width: 80,
            height: height,
            decoration: BoxDecoration(
              color: colors[rank - 1].withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                '$xp XP',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- NEW WIDGET: Persistent User Rank Banner ---
class _UserRankBanner extends StatelessWidget {
  final int rank;
  final String username;
  final int xp;
  const _UserRankBanner({
    required this.rank,
    required this.username,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return SlideInUp(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              '#$rank',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'You',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            Text(
              '$xp XP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- REFINED WIDGET: The Rank Tile for the list ---
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
    return ListTile(
      leading: SizedBox(
        width: 40,
        child: Center(
          child: Text('$rank', style: Theme.of(context).textTheme.titleMedium),
        ),
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
    );
  }
}
