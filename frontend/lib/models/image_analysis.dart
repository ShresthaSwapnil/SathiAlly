class ImageAnalysis {
  final bool isLikelyFake;
  final double confidenceScore;
  final List<String> analysisPoints;

  ImageAnalysis({
    required this.isLikelyFake,
    required this.confidenceScore,
    required this.analysisPoints,
  });

  factory ImageAnalysis.fromJson(Map<String, dynamic> json) {
    // Safely parse the list of strings
    var pointsFromJson = json['analysis_points'] as List;
    List<String> pointsList = pointsFromJson.map((i) => i.toString()).toList();

    // Safely parse the double, providing a default value if it fails
    double score = 0.0;
    if (json['confidence_score'] is num) {
      score = (json['confidence_score'] as num).toDouble();
    }

    return ImageAnalysis(
      isLikelyFake: json['is_likely_fake'] ?? false,
      confidenceScore: score,
      analysisPoints: pointsList,
    );
  }
}
