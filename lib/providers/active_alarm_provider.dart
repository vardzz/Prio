import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/reminder.dart';

final activeAlarmProvider = StateProvider<Reminder?>((ref) => null);
