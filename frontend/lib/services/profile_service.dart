import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:random_name_generator/random_name_generator.dart';

class ProfileService {
  final Box _profileBox = Hive.box('profile');
  final _uuid = Uuid();

  Future<void> initProfile() async {
    if (_profileBox.isEmpty) {
      final newId = _uuid.v4();
      final newName = RandomNames(Zone.us).name();
      await _profileBox.put('user_id', newId);
      await _profileBox.put('username', newName);
    }
  }

  Future<String> regenerateUsername() async {
    // Generate a new, different name
    final currentName = getUsername();
    String newName = currentName;
    while (newName == currentName) {
      newName = RandomNames(Zone.us).name();
    }

    // Save the new name to the Hive box
    await _profileBox.put('username', newName);
    return newName;
  }

  String getUserId() => _profileBox.get('user_id', defaultValue: 'unknown');
  String getUsername() =>
      _profileBox.get('username', defaultValue: 'Anonymous');
}
