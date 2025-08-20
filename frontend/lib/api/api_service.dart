import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/scenario.dart';
import 'package:frontend/models/score_response.dart';
import 'package:frontend/models/lesson.dart';

class ApiService {
  // Get the base URL from the environment variables
  final String? _baseUrl = dotenv.env['API_BASE_URL'];

  Future<Scenario> generateScenario({
    String? topic,
    bool isGentleMode = false,
  }) async {
    if (_baseUrl == null) {
      throw Exception("API_BASE_URL not found in .env file");
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/generate_scenario'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        // <-- Change to dynamic map
        'topic': topic, // Pass the topic
        'gentle_mode': isGentleMode,
      }),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      return Scenario.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      print('Failed to load scenario: ${response.body}');
      throw Exception('Failed to load scenario');
    }
  }

  // We will add the scoreReply method here in the next step.
  Future<ScoreResponse> scoreReply({
    required String scenarioId,
    required String userReply,
  }) async {
    if (_baseUrl == null) throw Exception("API_BASE_URL not found");

    final response = await http.post(
      Uri.parse('$_baseUrl/score'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'scenario_id': scenarioId,
        'user_reply': userReply,
        'locale': 'en',
      }),
    );

    if (response.statusCode == 200) {
      return ScoreResponse.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
    } else {
      print('Failed to get score: ${response.body}');
      throw Exception('Failed to get score from AI coach');
    }
  }

  Future<Lesson> generateLesson({required String topic}) async {
    if (_baseUrl == null) throw Exception("API_BASE_URL not found");

    final response = await http.post(
      Uri.parse('$_baseUrl/generate_lesson'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'topic': topic}),
    );

    if (response.statusCode == 200) {
      return Lesson.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('Failed to get lesson: ${response.body}');
      throw Exception('Failed to get lesson from AI');
    }
  }
}
