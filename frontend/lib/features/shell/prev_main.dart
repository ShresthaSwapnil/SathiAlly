import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:frontend/features/dojo/dojo_screen.dart';
import 'package:frontend/features/learn/learn_screen.dart';
import 'package:frontend/features/deepfake/deepfake_game_screen.dart';
import 'package:frontend/features/leaderboard/leaderboard_screen.dart';
import 'package:frontend/features/profile/profile_screen.dart';
import 'package:showcaseview/showcaseview.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const LearnScreen(),
    const DojoScreen(),
    const DeepfakeGameScreen(),
    const LeaderboardScreen(),
  ];

  final GlobalKey _learnKey = GlobalKey();
  final GlobalKey _dojoKey = GlobalKey();
  final GlobalKey _gameKey = GlobalKey();
  final GlobalKey _ranksKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();

  // We need to store the context from the builder to start the showcase
  BuildContext? _showcaseContext;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showcaseContext != null) {
        // Always start showcase in the same order as bottom nav + profile
        ShowCaseWidget.of(_showcaseContext!).startShowCase([
          _learnKey,
          _dojoKey,
          _gameKey,
          _ranksKey,
          _profileKey,
        ]);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) {
        // Store the special context provided by the ShowCaseWidget's builder
        _showcaseContext = context;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Netra'),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                ),
                icon: Showcase(
                  key: _profileKey,
                  title: 'Your Profile',
                  description:
                      'Check your stats, progress, and change your anonymous name here.',
                  titleTextAlign: TextAlign.center,
                  descriptionTextAlign: TextAlign.center,
                  child: const Icon(Iconsax.user),
                ),
                iconSize: 28,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _pages[_selectedIndex],
          ),
          bottomNavigationBar: _buildFloatingBottomNav(context),
        );
      },
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
            destinations: [
              Showcase(
                key: _learnKey,
                title: 'Learn Tab',
                description:
                    'Start here! Read AI-powered lessons on media literacy and take quizzes to earn XP.',
                child: const NavigationDestination(
                  icon: Icon(Iconsax.book),
                  selectedIcon: Icon(Iconsax.book_1),
                  label: 'Learn',
                ),
              ),
              Showcase(
                key: _dojoKey,
                title: 'Dojo Tab',
                description:
                    'Practice de-escalating tough online conversations in our AI-powered simulator.',
                child: const NavigationDestination(
                  icon: Icon(Iconsax.security),
                  selectedIcon: Icon(Iconsax.security_safe),
                  label: 'Dojo',
                ),
              ),
              Showcase(
                key: _gameKey,
                title: 'Analyzer Tool',
                description:
                    'Think an image is fake? Upload it here and let our AI analyze it for signs of manipulation.',
                child: const NavigationDestination(
                  icon: Icon(Iconsax.scan_barcode),
                  selectedIcon: Icon(Iconsax.scan),
                  label: 'Analyze',
                ),
              ),
              Showcase(
                key: _ranksKey,
                title: 'Ranks Tab',
                description:
                    'See how you stack up against other anonymous users on the global leaderboard.',
                child: const NavigationDestination(
                  icon: Icon(Iconsax.cup),
                  selectedIcon: Icon(Iconsax.cup),
                  label: 'Ranks',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
