import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reminder.dart';
import '../../providers/active_alarm_provider.dart';
import '../../providers/reminder_provider.dart';

class AlarmRingScreen extends ConsumerStatefulWidget {
  final Reminder reminder;

  const AlarmRingScreen({
    super.key,
    required this.reminder,
  });

  @override
  ConsumerState<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends ConsumerState<AlarmRingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $ampm';
  }

  String _getTypePrefixEmoji(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return '💊';
      case ReminderType.deadline:
        return '📌';
      case ReminderType.bill:
        return '💳';
      case ReminderType.custom:
        return '🔔';
    }
  }

  void _onDone() {
    // Complete reminder
    final updated = widget.reminder.copyWith(isCompleted: true);
    ref.read(reminderListProvider.notifier).updateReminder(updated);
    // Dismiss alarm
    ref.read(activeAlarmProvider.notifier).state = null;
  }

  void _onSnooze() {
    // Increment snooze count and delay by 10 minutes
    final updated = widget.reminder.copyWith(
      snoozeCount: widget.reminder.snoozeCount + 1,
      scheduledAt: DateTime.now().add(const Duration(minutes: 10)),
    );
    ref.read(reminderListProvider.notifier).updateReminder(updated);
    // Dismiss alarm
    ref.read(activeAlarmProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final isMedication = widget.reminder.type == ReminderType.medication;
    final typeLabel = widget.reminder.type.name[0].toUpperCase() + widget.reminder.type.name.substring(1);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // ios-bg
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),

              // Animated Pulsing Alarm Bell Centerpiece
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Pulse Ring
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 240 * _pulseAnimation.value,
                            height: 240 * _pulseAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFF3B30).withValues(alpha: 0.05), // pulsing red glow
                              border: Border.all(
                                color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                                width: 1.5,
                              ),
                            ),
                          );
                        },
                      ),
                      // Mid Pulse Ring
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 180 * (2 - _pulseAnimation.value),
                            height: 180 * (2 - _pulseAnimation.value),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFF3B30).withValues(alpha: 0.08),
                              border: Border.all(
                                color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                                width: 1.5,
                              ),
                            ),
                          );
                        },
                      ),
                      // Inner Solid Ring
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                          border: Border.all(
                            color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.notifications_active,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title and Subtitle Details
              Column(
                children: [
                  Text(
                    widget.reminder.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.38,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getTypePrefixEmoji(widget.reminder.type),
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$typeLabel · ${_formatTime(widget.reminder.scheduledAt)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8E8E93), // ios-muted
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Action Buttons
              Column(
                children: [
                  // Done Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24CF5F), // iOS green
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _onDone,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isMedication ? 'Done — I took it' : 'Done — I finished it',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Snooze Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF9F0A), width: 1.5), // orange border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      onPressed: _onSnooze,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.alarm, color: Color(0xFFFF9F0A), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Snooze 10 min',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF9F0A), // orange text
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Snooze tracker details
                  Text(
                    widget.reminder.snoozeCount == 0 
                        ? 'Not snoozed yet' 
                        : 'Snoozed ${widget.reminder.snoozeCount} of 3 times',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
