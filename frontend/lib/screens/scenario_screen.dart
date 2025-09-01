import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
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
    HapticFeedback.mediumImpact();
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
      // Error handling
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
      appBar: AppBar(
        title: const Text('Training Simulation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () =>
            FocusScope.of(context).unfocus(), 
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // --- The "Mission Briefing" ---
                  _MissionBriefing(scenario: widget.scenario),
                  const SizedBox(height: 24),

                  // --- The "Opponent's" Message ---
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _ChatBubble(
                      text: widget.scenario.hateSpeechComment,
                      isOpponent: true,
                    ),
                  ),
                ],
              ),
            ),

            // --- The User Input Area ---
            _UserInput(
              controller: _replyController,
              isSubmitting: _isSubmitting,
              onSubmit: _submitReply,
            ),
          ],
        ),
      ),
    );
  }
}

// --- NEW CUSTOM WIDGETS ---

class _MissionBriefing extends StatelessWidget {
  final Scenario scenario;
  const _MissionBriefing({required this.scenario});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Iconsax.info_circle),
        title: const Text(
          'Situation Briefing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Location:', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  scenario.context,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Their Perspective:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  scenario.characterPersona,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isOpponent;
  const _ChatBubble({required this.text, this.isOpponent = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: isOpponent ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isOpponent
              ? theme.colorScheme.surface
              : theme.colorScheme.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isOpponent
                ? const Radius.circular(4)
                : const Radius.circular(20),
            bottomRight: isOpponent
                ? const Radius.circular(20)
                : const Radius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isOpponent
                ? theme.textTheme.bodyLarge?.color
                : theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _UserInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _UserInput({
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Type your response...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            isSubmitting
                ? const CircularProgressIndicator()
                : IconButton(
                    icon: const Icon(Iconsax.send_1),
                    onPressed: onSubmit,
                    color: Theme.of(context).colorScheme.primary,
                    iconSize: 28,
                  ),
          ],
        ),
      ),
    );
  }
}
