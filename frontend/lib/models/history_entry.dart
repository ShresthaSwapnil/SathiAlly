import 'package:hive/hive.dart';

part 'history_entry.g.dart'; // This file will be generated

@HiveType(typeId: 0)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  final String scenarioContext;

  @HiveField(1)
  final String hateSpeechComment;

  @HiveField(2)
  final String userReply;

  @HiveField(3)
  final String suggestedRewrite;

  @HiveField(4)
  final int totalScore; // Storing total score for easy display

  @HiveField(5)
  final DateTime timestamp;

  HistoryEntry({
    required this.scenarioContext,
    required this.hateSpeechComment,
    required this.userReply,
    required this.suggestedRewrite,
    required this.totalScore,
    required this.timestamp,
  });
}
