import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/history_entry.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    HapticFeedback.mediumImpact();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Session History'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<HistoryEntry>('history').listenable(),
        builder: (context, Box<HistoryEntry> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text("You have no saved sessions yet."));
          }
          // Display newest entries first
          final entries = box.values.toList().reversed.toList();
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text(
                    entry.scenarioContext,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    DateFormat('MMM d, yyyy - hh:mm a').format(entry.timestamp),
                  ),
                  leading: CircleAvatar(
                    child: Text(entry.totalScore.toString()),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow("Scenario:", entry.hateSpeechComment),
                          const Divider(height: 24),
                          _buildDetailRow(
                            "Your Reply:",
                            entry.userReply,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            "Suggested Rewrite:",
                            entry.suggestedRewrite,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String title, String content, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(content),
      ],
    );
  }
}
