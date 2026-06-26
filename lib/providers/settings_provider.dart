import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

class SettingsState {
  final int snoozeLimit;
  final String defaultSound;
  final bool hapticFeedback;
  final bool criticalAlertsOverride;
  final bool notificationsPermission;

  SettingsState({
    this.snoozeLimit = 3,
    this.defaultSound = 'Radar',
    this.hapticFeedback = true,
    this.criticalAlertsOverride = true,
    this.notificationsPermission = false,
  });

  SettingsState copyWith({
    int? snoozeLimit,
    String? defaultSound,
    bool? hapticFeedback,
    bool? criticalAlertsOverride,
    bool? notificationsPermission,
  }) {
    return SettingsState(
      snoozeLimit: snoozeLimit ?? this.snoozeLimit,
      defaultSound: defaultSound ?? this.defaultSound,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      criticalAlertsOverride: criticalAlertsOverride ?? this.criticalAlertsOverride,
      notificationsPermission: notificationsPermission ?? this.notificationsPermission,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Box _box;

  SettingsNotifier(this._box) : super(SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final snoozeLimit = _box.get('snoozeLimit', defaultValue: 3) as int;
    final defaultSound = _box.get('defaultSound', defaultValue: 'Radar') as String;
    final hapticFeedback = _box.get('hapticFeedback', defaultValue: true) as bool;
    final criticalAlertsOverride = _box.get('criticalAlertsOverride', defaultValue: true) as bool;
    final notificationsPermission = _box.get('notificationsPermission', defaultValue: false) as bool;

    state = SettingsState(
      snoozeLimit: snoozeLimit,
      defaultSound: defaultSound,
      hapticFeedback: hapticFeedback,
      criticalAlertsOverride: criticalAlertsOverride,
      notificationsPermission: notificationsPermission,
    );
  }

  Future<void> updateSnoozeLimit(int limit) async {
    await _box.put('snoozeLimit', limit);
    state = state.copyWith(snoozeLimit: limit);
  }

  Future<void> updateDefaultSound(String sound) async {
    await _box.put('defaultSound', sound);
    state = state.copyWith(defaultSound: sound);
  }

  Future<void> updateHapticFeedback(bool enabled) async {
    await _box.put('hapticFeedback', enabled);
    state = state.copyWith(hapticFeedback: enabled);
  }

  Future<void> updateCriticalAlertsOverride(bool enabled) async {
    await _box.put('criticalAlertsOverride', enabled);
    state = state.copyWith(criticalAlertsOverride: enabled);
  }

  Future<void> updateNotificationsPermission(bool enabled) async {
    await _box.put('notificationsPermission', enabled);
    state = state.copyWith(notificationsPermission: enabled);
  }
}

final settingsBoxProvider = Provider<Box>((ref) {
  return Hive.box('settings_box');
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return SettingsNotifier(box);
});
