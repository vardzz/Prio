import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'presentation/screens/home_screen.dart';

class PrioApp extends StatelessWidget {
  const PrioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1C1C1E), // ios-bg
      ),
      home: const HomeScreen(),
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
