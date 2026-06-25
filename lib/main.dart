import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'data/models/reminder.dart';
import 'services/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(PriorityLevelAdapter());
  Hive.registerAdapter(ReminderAdapter());
  Hive.registerAdapter(ReminderTypeAdapter());
  Hive.registerAdapter(RepeatIntervalAdapter());
  await Hive.openBox<Reminder>('reminders_box');

  // Initialize Notifications
  await NotificationService.init();

  runApp(const ProviderScope(child: PrioApp()));
}