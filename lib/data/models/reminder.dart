import 'package:hive_ce/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 0)
enum PriorityLevel {
  @HiveField(0)
  normal,
  @HiveField(1)
  high,
  @HiveField(2)
  critical
}

@HiveType(typeId: 1)
class Reminder extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final DateTime scheduledAt;
  
  @HiveField(3)
  final PriorityLevel priority;

  Reminder({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.priority,
  });
}