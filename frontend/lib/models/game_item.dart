class GameItem {
  final String content;
  final bool isReal;
  final String explanation;

  GameItem({
    required this.content,
    required this.isReal,
    required this.explanation,
  });

  factory GameItem.fromJson(Map<String, dynamic> json) {
    return GameItem(
      content: json['content'],
      isReal: json['is_real'],
      explanation: json['explanation'],
    );
  }
}
