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

@HiveType(typeId: 2)
enum ReminderType {
  @HiveField(0)
  medication,
  @HiveField(1)
  deadline,
  @HiveField(2)
  bill,
  @HiveField(3)
  custom
}

@HiveType(typeId: 3)
enum RepeatInterval {
  @HiveField(0)
  everyFourHours,
  @HiveField(1)
  everySixHours,
  @HiveField(2)
  everyEightHours,
  @HiveField(3)
  everyTwelveHours,
  @HiveField(4)
  daily,
  @HiveField(5)
  weekly,
  @HiveField(6)
  monthly
}

@HiveType(typeId: 1)
class Reminder extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final ReminderType type;
  
  @HiveField(4)
  final DateTime scheduledAt;
  
  @HiveField(5)
  final RepeatInterval? repeat;
  
  @HiveField(6)
  final PriorityLevel priority;
  
  @HiveField(7)
  final bool isCompleted;
  
  @HiveField(8)
  final DateTime? acknowledgedAt;
  
  @HiveField(9)
  final int snoozeCount;

  Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.scheduledAt,
    this.repeat,
    required this.priority,
    this.isCompleted = false,
    this.acknowledgedAt,
    this.snoozeCount = 0,
  });

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    ReminderType? type,
    DateTime? scheduledAt,
    RepeatInterval? repeat,
    PriorityLevel? priority,
    bool? isCompleted,
    DateTime? acknowledgedAt,
    int? snoozeCount,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      repeat: repeat ?? this.repeat,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      snoozeCount: snoozeCount ?? this.snoozeCount,
    );
  }
}