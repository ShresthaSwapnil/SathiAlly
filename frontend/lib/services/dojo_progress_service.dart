import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class DojoProgressService {
  final Box _progressBox = Hive.box('dojo_progress');

  String _getTodayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> completeSession() async {
    final key = _getTodayKey();
    int sessionsToday = _progressBox.get(key, defaultValue: 0);
    await _progressBox.put(key, sessionsToday + 1);
  }

  int getSessionsCompletedToday() {
    return _progressBox.get(_getTodayKey(), defaultValue: 0);
  }
}
