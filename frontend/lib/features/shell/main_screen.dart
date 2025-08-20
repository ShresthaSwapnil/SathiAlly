import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:frontend/features/dojo/dojo_screen.dart';
import 'package:frontend/features/learn/learn_screen.dart';
import 'package:frontend/features/deepfake/deepfake_game_screen.dart';
import 'package:frontend/features/leaderboard/leaderboard_screen.dart';
import 'package:frontend/features/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of the main screens for each tab. Use `final` instead of `const` for flexibility.
  // We add `const` before each widget since they have const constructors.
  static final List<Widget> _pages = <Widget>[
    const LearnScreen(), // Index 0
    const DojoScreen(), // Index 1
    const DeepfakeGameScreen(), // Index 2
    const LeaderboardScreen(), // Index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Netra'),
        actions: [
          IconButton(
            onPressed: () {
              // v-- UPDATE THIS --v
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            icon: const Icon(Iconsax.user),
            iconSize: 28,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildFloatingBottomNav(context),
    );
  }

  Widget _buildFloatingBottomNav(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: NavigationBar(
            onDestinationSelected: _onItemTapped,
            selectedIndex: _selectedIndex,
            backgroundColor: Colors.transparent,
            indicatorColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.1),
            elevation: 0,
            destinations: <Widget>[
              NavigationDestination(
                selectedIcon: Icon(
                  Iconsax.book_1,
                  color: Theme.of(context).colorScheme.primary,
                ),
                icon: const Icon(Iconsax.book),
                label: 'Learn',
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Iconsax.security_safe,
                  color: Theme.of(context).colorScheme.primary,
                ),
                icon: const Icon(Iconsax.security),
                label: 'Dojo',
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Iconsax.gameboy,
                  color: Theme.of(context).colorScheme.primary,
                ),
                icon: const Icon(Iconsax.game),
                label: 'Game',
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Iconsax.cup,
                  color: Theme.of(context).colorScheme.primary,
                ),
                icon: const Icon(Iconsax.cup),
                label: 'Ranks',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
