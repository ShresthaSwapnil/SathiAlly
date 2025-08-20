import 'package:hive/hive.dart';

part 'player_progress.g.dart';

@HiveType(typeId: 1)
class PlayerProgress extends HiveObject {
  @HiveField(0)
  int totalXp;

  @HiveField(1)
  int streakCount;

  @HiveField(2)
  DateTime lastSessionDate;

  PlayerProgress({
    required this.totalXp,
    required this.streakCount,
    required this.lastSessionDate,
  });
}
