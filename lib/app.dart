import 'package:flutter/material.dart';
import 'services/notification_service.dart';

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
