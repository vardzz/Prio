import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import '../data/models/reminder.dart';
import '../data/repositories/reminder_repository.dart';

// Provider for the Hive Box
final remindersBoxProvider = Provider<Box<Reminder>>((ref) {
  return Hive.box<Reminder>('reminders_box');
});

// Provider for the Repository
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final box = ref.watch(remindersBoxProvider);
  return ReminderRepository(box);
});

// StateNotifier to manage the list state and operations
class ReminderListNotifier extends StateNotifier<List<Reminder>> {
  final ReminderRepository _repository;

  ReminderListNotifier(this._repository) : super([]) {
    _loadReminders();
  }

  void _loadReminders() {
    state = _repository.list();
  }

  Future<void> addReminder(Reminder reminder) async {
    await _repository.create(reminder);
    _loadReminders();
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _repository.update(reminder);
    _loadReminders();
  }

  Future<void> deleteReminder(String id) async {
    await _repository.delete(id);
    _loadReminders();
  }
}

// Provider for the StateNotifier
final reminderListProvider = StateNotifierProvider<ReminderListNotifier, List<Reminder>>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return ReminderListNotifier(repository);
});
