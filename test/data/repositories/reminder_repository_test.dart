import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:prio/data/models/reminder.dart';
import 'package:prio/data/repositories/reminder_repository.dart';

void main() {
  late Box<Reminder> box;
  late ReminderRepository repository;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    
    try {
      Hive.registerAdapter(PriorityLevelAdapter());
      Hive.registerAdapter(ReminderTypeAdapter());
      Hive.registerAdapter(RepeatIntervalAdapter());
      Hive.registerAdapter(ReminderAdapter());
    } catch (_) {
      // Already registered
    }

    box = await Hive.openBox<Reminder>('test_reminders_box');
    repository = ReminderRepository(box);
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  test('CRUD operations', () async {
    final reminder = Reminder(
      id: '1',
      title: 'Test Medication',
      type: ReminderType.medication,
      scheduledAt: DateTime(2026, 6, 25, 8, 0),
      priority: PriorityLevel.critical,
    );

    // Create
    await repository.create(reminder);
    expect(repository.read('1'), isNotNull);
    expect(repository.read('1')!.title, 'Test Medication');

    // Update
    final updated = reminder.copyWith(title: 'Updated Medication');
    await repository.update(updated);
    expect(repository.read('1')!.title, 'Updated Medication');

    // List
    final list = repository.list();
    expect(list.length, 1);
    expect(list.first.title, 'Updated Medication');

    // Delete
    await repository.delete('1');
    expect(repository.read('1'), isNull);
    expect(repository.list().isEmpty, true);
  });

  test('List is sorted by scheduledAt', () async {
    final r1 = Reminder(
      id: '1',
      title: 'Later reminder',
      type: ReminderType.custom,
      scheduledAt: DateTime(2026, 6, 25, 10, 0),
      priority: PriorityLevel.normal,
    );
    final r2 = Reminder(
      id: '2',
      title: 'Earlier reminder',
      type: ReminderType.custom,
      scheduledAt: DateTime(2026, 6, 25, 9, 0),
      priority: PriorityLevel.normal,
    );

    await repository.create(r1);
    await repository.create(r2);

    final list = repository.list();
    expect(list.length, 2);
    expect(list[0].id, '2');
    expect(list[1].id, '1');
  });
}
