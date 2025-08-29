import 'package:hive/hive.dart';

class LearnProgressService {
  final Box<String> _completedLessonsBox = Hive.box<String>(
    'completed_lessons',
  );

  // Method to add a topic to the list of completed lessons.
  // We use the topic title as a unique key.
  Future<void> completeLesson(String topicTitle) async {
    await _completedLessonsBox.put(topicTitle, topicTitle);
  }

  // Method to check if a specific lesson has been completed.
  bool isLessonCompleted(String topicTitle) {
    return _completedLessonsBox.containsKey(topicTitle);
  }

  // Method to get a list of all completed lesson titles.
  List<String> getCompletedLessons() {
    return _completedLessonsBox.values.toList();
  }
}
