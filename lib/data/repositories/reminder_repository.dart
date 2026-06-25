import 'package:hive_ce/hive.dart';
import '../models/reminder.dart';

class ReminderRepository {
  final Box<Reminder> _box;

  ReminderRepository(this._box);

  Future<void> create(Reminder reminder) async {
    await _box.put(reminder.id, reminder);
  }

  Reminder? read(String id) {
    return _box.get(id);
  }

  Future<void> update(Reminder reminder) async {
    await _box.put(reminder.id, reminder);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  List<Reminder> list() {
    final reminders = _box.values.toList();
    reminders.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return reminders;
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
