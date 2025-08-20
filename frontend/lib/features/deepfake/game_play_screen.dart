import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/models/game_item.dart';
import 'package:frontend/features/deepfake/game_results_screen.dart';

const int TOTAL_ROUNDS = 5;
const int ROUND_DURATION = 15; // 10 seconds per round

class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({super.key});
  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  final ApiService _apiService = ApiService();
  GameItem? _currentItem;
  bool _isLoading = true;
  int _currentRound = 1;
  int _score = 0;

  Timer? _timer;
  int _timeLeft = ROUND_DURATION;

  bool _answered = false;
  bool? _wasCorrect;

  @override
  void initState() {
    super.initState();
    _fetchNextItem();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft = ROUND_DURATION;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _handleAnswer(userChoice: null); // Timeout
      }
    });
  }

  void _fetchNextItem() async {
    setState(() {
      _isLoading = true;
      _answered = false;
      _wasCorrect = null;
    });
    try {
      final item = await _apiService.generateGameItem();
      setState(() {
        _currentItem = item;
        _isLoading = false;
      });
      _startTimer();
    } catch (e) {
      // Handle error
    }
  }

  void _handleAnswer({required bool? userChoice}) {
    if (_answered) return;
    _timer?.cancel();
    setState(() {
      _answered = true;
      if (userChoice == _currentItem!.isReal) {
        _wasCorrect = true;
        _score++;
      } else {
        _wasCorrect = false;
      }
    });
  }

  void _nextRound() {
    if (_currentRound < TOTAL_ROUNDS) {
      setState(() => _currentRound++);
      _fetchNextItem();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              GameResultsScreen(score: _score, totalRounds: TOTAL_ROUNDS),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Round $_currentRound / $TOTAL_ROUNDS')),
      body: _isLoading || _currentItem == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: _timeLeft / ROUND_DURATION),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: Text(
                        _currentItem!.content,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                  if (_answered) ...[
                    Card(
                      color: _wasCorrect!
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          _currentItem!.explanation,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _nextRound,
                      child: const Text('Next'),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: () => _handleAnswer(userChoice: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Real'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _handleAnswer(userChoice: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Fake'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
