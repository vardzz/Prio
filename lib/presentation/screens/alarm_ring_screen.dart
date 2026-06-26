import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reminder.dart';
import '../../providers/settings_provider.dart';
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
    final settings = ref.watch(settingsProvider);
    final isSnoozeLimitReached = widget.reminder.snoozeCount >= settings.snoozeLimit;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // ios-bg
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Space placeholder
              const SizedBox(height: 10),

              // Centered Pulse and Title
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Radial Glowing Waves (Pulse Animation)
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 200 * _pulseAnimation.value,
                            height: 200 * _pulseAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 150 * _pulseAnimation.value,
                            height: 150 * _pulseAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFF3B30).withValues(alpha: 0.05),
                            ),
                          );
                        },
                      ),
                      // Core Bell Icon Container
                      Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2C2C2E), // bg-surface
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.notifications_active,
                            color: Color(0xFFFF3B30),
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Reminder Title
                  Text(
                    widget.reminder.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle info
                  Text(
                    '${_getTypePrefixEmoji(widget.reminder.type)} $typeLabel · ${_formatTime(widget.reminder.scheduledAt)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),

              // Bottom buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Done Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF30D158), // Green
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
                        side: BorderSide(
                          color: isSnoozeLimitReached ? const Color(0xFF3A3A3C) : const Color(0xFFFF9F0A),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      onPressed: isSnoozeLimitReached ? null : _onSnooze,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.alarm,
                            color: isSnoozeLimitReached ? const Color(0xFF8E8E93) : const Color(0xFFFF9F0A),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isSnoozeLimitReached ? 'Snooze Limit Reached' : 'Snooze 10 min',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isSnoozeLimitReached ? const Color(0xFF8E8E93) : const Color(0xFFFF9F0A),
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
                        : 'Snoozed ${widget.reminder.snoozeCount} of ${settings.snoozeLimit} times',
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
