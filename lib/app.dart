import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/notification_service.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/alarm_ring_screen.dart';
import 'providers/active_alarm_provider.dart';
import 'providers/reminder_provider.dart';

class PrioApp extends ConsumerStatefulWidget {
  const PrioApp({super.key});

  @override
  ConsumerState<PrioApp> createState() => _PrioAppState();
}

class _PrioAppState extends ConsumerState<PrioApp> {
  Timer? _alarmTimer;

  @override
  void initState() {
    super.initState();
    // Check for due reminders every 5 seconds
    _alarmTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkAlarms();
    });
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    super.dispose();
  }

  void _checkAlarms() {
    final activeAlarm = ref.read(activeAlarmProvider);
    if (activeAlarm != null) return; // Already ringing an alarm

    final reminders = ref.read(reminderListProvider);
    final now = DateTime.now();

    for (final r in reminders) {
      if (!r.isCompleted && r.scheduledAt.isBefore(now)) {
        // Trigger the alarm screen overlay
        ref.read(activeAlarmProvider.notifier).state = r;
        break; // Only trigger one alarm at a time
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeAlarm = ref.watch(activeAlarmProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1C1C1E), // ios-bg
      ),
      home: activeAlarm != null 
          ? AlarmRingScreen(reminder: activeAlarm) 
          : const HomeScreen(),
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
