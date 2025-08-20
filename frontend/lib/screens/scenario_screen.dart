import 'package:flutter/material.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/models/scenario.dart';
import 'package:frontend/models/score_response.dart';
import 'package:frontend/screens/feedback_screen.dart';

class ScenarioScreen extends StatefulWidget {
  final Scenario scenario;
  const ScenarioScreen({super.key, required this.scenario});

  @override
  State<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  final TextEditingController _replyController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isSubmitting = false;

  void _submitReply() async {
    if (_replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a reply.')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final ScoreResponse feedback = await _apiService.scoreReply(
        scenarioId: widget.scenario.scenarioId,
        userReply: _replyController.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FeedbackScreen(
              scenario: widget.scenario,
              userReply: _replyController.text,
              feedback: feedback,
            ),
          ),
        );
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
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice Scenario')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          // Padding is now the direct child of the scroll view
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Context Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THE SITUATION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent[100],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.scenario.context),
                      const SizedBox(height: 12),
                      Text(
                        'Their perspective: ${widget.scenario.characterPersona}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Hate Speech Comment
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red[900]?.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${widget.scenario.hateSpeechComment}"',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // User Reply Text Field
              TextField(
                controller: _replyController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Your Reply',
                  hintText: 'Type your response here...',
                ),
                maxLines: 4,
              ),
              const SizedBox(
                height: 24,
              ), // Replaces the Spacer with a fixed space
              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReply,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit for Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
