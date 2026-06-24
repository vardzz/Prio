import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'data/models/reminder.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(PriorityLevelAdapter());
  Hive.registerAdapter(ReminderAdapter());
  await Hive.openBox<Reminder>('reminders_box');

  // Initialize Notifications
  await NotificationService.init();

  runApp(const ProviderScope(child: PrioApp()));
}

class PrioApp extends StatelessWidget {
  const PrioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      ),
      home: const PhaseZeroScreen(),
    );
  }
}

class PhaseZeroScreen extends StatelessWidget {
  const PhaseZeroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PRIO.',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
            ),
            const SizedBox(height: 8),
            const Text('Phase 0 Diagnostic Setup', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                await NotificationService.triggerTestNotification();
              },
              child: const Text('Fire System Test Notification'),
            ),
          ],
        ),
      ),
    );
  }
}