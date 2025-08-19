import 'package:flutter/foundation.dart';

class Score {
  final String criterion;
  final int score;
  final String rationale;

  Score({
    required this.criterion,
    required this.score,
    required this.rationale,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      criterion: json['criterion'],
      score: json['score'],
      rationale: json['rationale'],
    );
  }
}

class ScoreResponse {
  final List<Score> scores;
  final String suggestedRewrite;
  final List<String> safetyFlags;

  ScoreResponse({
    required this.scores,
    required this.suggestedRewrite,
    required this.safetyFlags,
  });

  factory ScoreResponse.fromJson(Map<String, dynamic> json) {
    // Safely parse the list of scores
    var scoresList = json['scores'] as List;
    List<Score> scores = scoresList.map((i) => Score.fromJson(i)).toList();

    // Safely parse the list of safety flags
    var flagsList = json['safety_flags'] as List;
    List<String> safetyFlags = flagsList.map((i) => i.toString()).toList();

    return ScoreResponse(
      scores: scores,
      suggestedRewrite: json['suggested_rewrite'],
      safetyFlags: safetyFlags,
    );
  }
}
