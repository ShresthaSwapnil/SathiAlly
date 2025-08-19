import 'package:flutter/material.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/models/scenario.dart';
import 'package:frontend/screens/scenario_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  void _startNewSession(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch a new scenario from our backend
      final Scenario scenario = await _apiService.generateScenario();

      // Navigate to the ScenarioScreen if the widget is still in the tree
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScenarioScreen(scenario: scenario),
          ),
        );
      }
    } catch (e) {
      // Show an error message if something goes wrong
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      // Ensure the loading indicator is turned off
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sathi Ally'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // ... (The rest of the UI from before remains the same)
              const Icon(
                Icons.security,
                size: 80,
                color: Colors.deepPurpleAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to your Dialogue Dojo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Practice responding to tough online conversations in a safe space.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Show a loading indicator or the button
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: () => _startNewSession(context),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Practice Session'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
