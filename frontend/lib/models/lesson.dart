class Lesson {
  final String title;
  final List<String> content;
  final String example;

  Lesson({required this.title, required this.content, required this.example});

  factory Lesson.fromJson(Map<String, dynamic> json) {
    // Convert the list of content from List<dynamic> to List<String>
    var contentFromJson = json['content'] as List;
    List<String> contentList = contentFromJson
        .map((i) => i.toString())
        .toList();

    return Lesson(
      title: json['title'],
      content: contentList,
      example: json['example'],
    );
  }
}
