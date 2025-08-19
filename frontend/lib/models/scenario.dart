class Scenario {
  final String scenarioId;
  final String context;
  final String hateSpeechComment;
  final String characterPersona;

  Scenario({
    required this.scenarioId,
    required this.context,
    required this.hateSpeechComment,
    required this.characterPersona,
  });

  // A factory constructor for creating a new Scenario instance from a map (JSON).
  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      scenarioId: json['scenario_id'],
      context: json['context'],
      hateSpeechComment: json['hate_speech_comment'],
      characterPersona: json['character_persona'],
    );
  }
}
