# CriticalAlert — Project Plan
> A local, offline-first Flutter app for unmissable critical notifications.

---

## Table of Contents
1. [Project Vision](#1-project-vision)
2. [Recommended Improvements](#2-recommended-improvements)
3. [Final Tech Stack](#3-final-tech-stack)
4. [App Architecture](#4-app-architecture)
5. [Screen Inventory & UX Flow](#5-screen-inventory--ux-flow)
6. [Feature Breakdown](#6-feature-breakdown)
7. [Platform-Specific Implementation Notes](#7-platform-specific-implementation-notes)
8. [Development Phases](#8-development-phases)
9. [File & Folder Structure](#9-file--folder-structure)
10. [Risk Register](#10-risk-register)

---

## 1. Project Vision

**CriticalAlert** is an offline-first Flutter mobile application whose sole purpose is ensuring users never miss a life-critical event — medication doses, hard deadlines, or emergency reminders — even when the device is on silent or Do Not Disturb.

**Success looks like:** A user on full DND hears a loud alarm and sees a full-screen takeover when their medication time arrives.

---

## 2. Recommended Improvements

The original concept is solid. Below are concrete recommendations to make it significantly better before a single line of code is written.

### 2.1 Add Lightweight Persistence (Critical Fix)
**Problem:** In-memory-only storage means every reminder disappears when the app is closed. The system alarm might still fire, but the user's list will be blank when they reopen the app — this is a confusing, broken experience.

**Recommendation:** Use **Hive** (preferred over `shared_preferences` for list data) as a zero-config, offline key-value store. It takes roughly 30 minutes to wire up and completely solves this problem. Think of it as a JSON file that persists on the device.

### 2.2 Introduce a "Reminder Type" System
Instead of one flat list, categorize reminders into typed presets. This makes the UI instantly readable and allows future extensibility.

| Type | Icon | Default Priority | Repeat Logic |
|---|---|---|---|
| Medication | 💊 | CRITICAL | Every X hours |
| Hard Deadline | 📌 | HIGH | One-time + escalating warnings |
| Bill / Payment | 💳 | HIGH | Monthly recurrence |
| Custom | ⚙️ | User-set | User-set |

### 2.3 Escalating Notification Cascade
A single notification before a deadline is easy to dismiss and forget. Instead, schedule a cascade:

- **2 hours before** → Standard priority notification (silent banner)
- **30 minutes before** → High priority notification (sound, heads-up)
- **At deadline** → CRITICAL alarm (DND bypass, full-screen if possible)
- **15 minutes after (missed)** → Repeat critical alarm every 5 min until dismissed

### 2.4 "Snooze with Accountability" Instead of Simple Dismiss
Regular alarms are dismissible. For a critical alert app, add a **confirm-receipt** pattern:

- Alarm fires → User sees a full-screen overlay
- Two buttons: **"Done — I took it"** vs. **"Snooze 10 min"**
- Snooze is allowed a maximum of 2 times before it locks to "Done" only
- Log the action with a timestamp (stored in Hive) for accountability

### 2.5 Minimal Home Screen Widget (Stretch Goal)
A home screen widget showing the next 2–3 upcoming critical reminders would be genuinely useful. Flutter supports this via `home_widget` package. Mark it as a v2 feature — don't let it block v1.

### 2.6 Per-Reminder Volume Override
Let users set a specific alarm volume (0–100%) per reminder, independent of device volume. This is achievable on Android via `AudioManager`. On iOS it is not possible due to platform restrictions — document this clearly in the UI.

---

## 3. Final Tech Stack

| Concern | Package / Tool | Reason |
|---|---|---|
| Framework | Flutter (Dart) | Cross-platform, single codebase |
| Local notifications | `flutter_local_notifications` ^18 | Industry standard, supports channels + critical alerts |
| Precise alarm scheduling | `android_alarm_manager_plus` | Survives app kill + Doze mode on Android |
| Local persistence | `hive` + `hive_flutter` | Lightweight, offline, no SQL needed |
| State management | `riverpod` (or `provider` if simpler) | Clean separation of UI from business logic |
| Unique IDs | `uuid` | Required to identify and cancel specific notifications |
| Date/time picking | `omni_datetime_range_picker` | Better UX than Flutter's default pickers |
| Permissions | `permission_handler` | Unified API for all runtime permissions |
| Timezone handling | `timezone` | Required by `flutter_local_notifications` for exact scheduling |

---

## 4. App Architecture

Use a simple **3-layer architecture** — appropriate for a project of this scope, and easy to reason about as a first mobile project.

```
┌──────────────────────────────────┐
│           UI Layer               │  Widgets, Screens, Theme
├──────────────────────────────────┤
│        Logic / State Layer       │  Riverpod Providers, Use Cases
├──────────────────────────────────┤
│        Data / Service Layer      │  Hive repositories, Notification Service
└──────────────────────────────────┘
```

**Key Services:**
- `NotificationService` — wraps `flutter_local_notifications`, handles scheduling, cancelling, channel setup
- `ReminderRepository` — wraps Hive box, handles CRUD for all reminders
- `AlarmService` — wraps `android_alarm_manager_plus` for Android-specific exact alarms
- `PermissionService` — checks and requests all required permissions on startup

**Data Model — `Reminder`:**
```dart
class Reminder {
  String id;            // UUID
  String title;
  String? description;
  ReminderType type;    // medication | deadline | bill | custom
  DateTime scheduledAt;
  RepeatInterval? repeat; // null = one-time
  Priority priority;    // critical | high | normal
  bool isCompleted;
  DateTime? acknowledgedAt;
  int snoozeCount;
}
```

---

## 5. Screen Inventory & UX Flow

```
App Launch
    │
    ▼
[Onboarding / Permission Guard]  ← First launch only
    │  (All permissions granted)
    ▼
[Home — Reminder List]
    │
    ├──► [+ Add Reminder]  →  [Reminder Form]
    │                               │
    │                    [Preset Quick-Add Sheets]
    │                    💊 Medication | 📌 Deadline | 💳 Bill | ⚙️ Custom
    │
    ├──► [Reminder Detail / Edit]
    │
    └──► [Settings]
              ├── Default alarm sound
              ├── Snooze limit
              └── About / Permissions status
```

### Screens in Detail

| Screen | Purpose |
|---|---|
| **Onboarding / Permission Guard** | One-time screen guiding user through all permission grants with plain-language explanations |
| **Home** | Scrollable list of all reminders, grouped by "Upcoming Today", "This Week", "Later". Swipe to delete, tap to edit. |
| **Add / Edit Reminder** | Form for all reminder fields. Bottom-sheet preset cards at the top for quick-fill. |
| **Active Alarm Overlay** | Full-screen takeover when a critical alarm fires while the app is in foreground. |
| **Settings** | Alarm tone selector, snooze limits, permission status indicators |

---

## 6. Feature Breakdown

### F1 — Permission Guard (Onboarding)
- Check `POST_NOTIFICATIONS` (Android 13+)
- Check `SCHEDULE_EXACT_ALARM` (Android 14+)
- Check `ACCESS_NOTIFICATION_POLICY` for DND override
- Check iOS `criticalAlert` entitlement availability
- Display a clear card per permission: icon, why it's needed, a "Grant" button
- Do not proceed to Home until critical permissions are granted; advisory permissions can be skipped

### F2 — Reminder CRUD
- Create reminders with type, title, date/time, repeat interval, priority
- Edit any existing reminder (updates scheduled notification automatically)
- Delete reminder (cancels scheduled notification via stored UUID-mapped notification ID)
- Mark as complete (visually strikes through; keeps in history for 7 days then auto-deletes)

### F3 — Notification Scheduling
- One-time reminders: schedule single notification at `scheduledAt`
- Repeating reminders: use `flutter_local_notifications` periodic scheduling or manually re-schedule on notification received
- Escalating cascade: for HIGH/CRITICAL priority, schedule 3 notification IDs per reminder (2hr warning, 30min warning, at-time alarm)
- On Android: route CRITICAL reminders through `android_alarm_manager_plus` for reliability

### F4 — DND Bypass
- **Android:** Create notification channel with `Importance.max` + `AudioAttributes.USAGE_ALARM`. Guide user to grant "Override Do Not Disturb" in system settings. For absolute bypass, use full-screen intent via AlarmManager.
- **iOS:** Request `criticalAlert` permission via `flutter_local_notifications` iOS settings. Works in dev/TestFlight; requires Apple entitlement for App Store.

### F5 — Alarm Acknowledgment
- When alarm fires, show a confirmation dialog (or full-screen overlay if app is foreground)
- Options: "Done" (dismisses + logs timestamp) or "Snooze 10 min" (max 2 times)
- After 2 snoozes, only "Done" is available
- Store acknowledgment timestamp in Hive alongside the reminder

### F6 — Quick-Add Presets
- **Medication preset:** Asks for medication name, dosage note, start time, repeat interval (every 4/6/8/12/24 hours). Auto-sets CRITICAL priority.
- **Hard Deadline preset:** Asks for task name, due date/time. Auto-schedules 3-notification cascade. Auto-sets HIGH priority.
- **Bill preset:** Asks for bill name, amount (optional), due date, recurrence (monthly). Auto-sets HIGH priority.

### F7 — Home Screen Display
- Reminders grouped into sections: "Today", "Upcoming (7 days)", "Later"
- Color-coded left border per priority: Red = CRITICAL, Orange = HIGH, Grey = NORMAL
- Completed reminders shown at bottom, muted, with checkmark
- Empty state illustration + CTA when no reminders exist

---

## 7. Platform-Specific Implementation Notes

### Android
```
Min SDK: 21 (Android 5.0)
Target SDK: 34 (Android 14)

AndroidManifest.xml additions needed:
  <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
  <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
  <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
  <uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY"/>
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

Notification Channel setup (in NotificationService.init()):
  - channelId: "critical_alerts"
  - importance: Importance.max
  - enableVibration: true
  - playSound: true
  - audioAttributesUsage: AudioAttributesUsage.alarm
```

**Doze Mode Warning:** Android Doze mode can delay inexact alarms. Always use exact alarms (`setExactAndAllowWhileIdle`) for CRITICAL reminders via `android_alarm_manager_plus`.

**Boot Receiver:** Register a `BootReceiver` to reschedule all pending alarms when the device restarts, as AlarmManager clears on reboot. Read all reminders from Hive and re-schedule on boot.

### iOS
```
Min iOS: 14.0
Deployment target: 16.0+

Info.plist additions:
  NSUserNotificationsUsageDescription (required)

Entitlements needed for production:
  com.apple.developer.usernotifications.critical-alerts
  (Apply at: developer.apple.com → App IDs → Capabilities)

flutter_local_notifications iOS config:
  requestCriticalPermission: true
  requestAlertPermission: true
  requestSoundPermission: true
```

**Important iOS Limitation:** Volume override per-notification is NOT possible on iOS. Alarm volume follows system volume. Document this to the user in the permission guard screen.

---

## 8. Development Phases

### Phase 0 — Project Setup (Day 1–2)
- [ ] `flutter create critical_alert`
- [ ] Add all dependencies to `pubspec.yaml`
- [ ] Set up Android `AndroidManifest.xml` permissions
- [ ] Set up iOS `Info.plist` and entitlements stub
- [ ] Initialize Hive with `ReminderAdapter`
- [ ] Initialize `flutter_local_notifications` with channel config
- [ ] Verify a test notification fires correctly on both platforms

### Phase 1 — Core Data Layer (Day 3–4)
- [ ] Define `Reminder` model with `HiveType` annotations
- [ ] Build `ReminderRepository` (create, read, update, delete, list)
- [ ] Write unit tests for repository
- [ ] Set up Riverpod providers for reminder list state

### Phase 2 — Permission Guard Screen (Day 5–6)
- [ ] Build onboarding screen UI
- [ ] Wire up `permission_handler` for each required permission
- [ ] Build "deep link to system settings" buttons for special permissions
- [ ] Persist "onboarding complete" flag in Hive; skip on subsequent launches

### Phase 3 — Home Screen (Day 7–9)
- [ ] Build reminder list UI with grouping (Today / Upcoming / Later)
- [ ] Color coding per priority
- [ ] Swipe-to-delete with undo snackbar
- [ ] Empty state
- [ ] Connect to Riverpod provider (reactive list updates)

### Phase 4 — Add / Edit Reminder (Day 10–13)
- [ ] Build reminder form screen
- [ ] Implement all 4 preset quick-add bottom sheets
- [ ] Date/time picker integration
- [ ] Repeat interval selector
- [ ] Form validation
- [ ] On save: write to Hive + schedule notification(s)
- [ ] On edit: cancel old notification(s) + reschedule

### Phase 5 — Notification Engine (Day 14–17)
- [ ] Implement `NotificationService` with full channel setup
- [ ] Implement scheduling logic for each priority level (single / cascade)
- [ ] Implement DND bypass channel on Android
- [ ] Implement AlarmManager integration for CRITICAL on Android
- [ ] Implement Boot Receiver for rescheduling on Android
- [ ] Test all notification scenarios on real devices

### Phase 6 — Alarm Acknowledgment (Day 18–19)
- [ ] Notification tap → open app to reminder detail
- [ ] In-app full-screen alarm overlay for foreground alarms
- [ ] "Done" / "Snooze" action buttons
- [ ] Snooze counter enforcement (max 2)
- [ ] Log acknowledgment timestamp to Hive

### Phase 7 — Settings Screen (Day 20–21)
- [ ] Alarm sound selector (from bundled assets)
- [ ] Snooze limit setting (1–3)
- [ ] Permission status indicators with re-request buttons
- [ ] App version / about info

### Phase 8 — Polish & QA (Day 22–25)
- [ ] Dark mode theme pass (enforce dark-only or auto-detect)
- [ ] Typography and spacing audit
- [ ] Test on Android 10, 12, 14 physical devices
- [ ] Test on iOS 16+ simulator and physical device
- [ ] Edge cases: reminder in the past, device restart, app killed, timezone change
- [ ] Performance: open Hive box read time with 100+ reminders

---

## 9. File & Folder Structure

```
lib/
├── main.dart
├── app.dart                          # MaterialApp, theme, router
│
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   └── notification_ids.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── date_utils.dart
│
├── data/
│   ├── models/
│   │   ├── reminder.dart             # Hive model + adapter
│   │   └── reminder.g.dart           # Generated by hive_generator
│   └── repositories/
│       └── reminder_repository.dart
│
├── services/
│   ├── notification_service.dart
│   ├── alarm_service.dart            # Android AlarmManager wrapper
│   └── permission_service.dart
│
├── providers/
│   └── reminder_provider.dart        # Riverpod providers
│
└── ui/
    ├── screens/
    │   ├── onboarding/
    │   │   └── permission_guard_screen.dart
    │   ├── home/
    │   │   └── home_screen.dart
    │   ├── reminder_form/
    │   │   └── reminder_form_screen.dart
    │   ├── settings/
    │   │   └── settings_screen.dart
    │   └── alarm_overlay/
    │       └── alarm_overlay_screen.dart
    └── widgets/
        ├── reminder_card.dart
        ├── priority_badge.dart
        ├── preset_sheet.dart
        └── permission_card.dart

android/
├── app/src/main/
│   ├── AndroidManifest.xml
│   └── kotlin/.../
│       ├── MainActivity.kt
│       └── BootReceiver.kt           # Reschedule alarms on boot

ios/
└── Runner/
    ├── Info.plist
    └── Runner.entitlements
```

---

## 10. Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| iOS Critical Alerts rejected by Apple for App Store | High | High | Use for personal/dev use; document limitation clearly. For production, apply for entitlement early. |
| Android Doze mode silences exact alarms | Medium | High | Always use `USE_EXACT_ALARM` + `android_alarm_manager_plus` for CRITICAL reminders |
| Device restart clears scheduled alarms | High | High | Implement Boot Receiver to re-read Hive and reschedule everything |
| User denies notification permission | Medium | Critical | Graceful degradation: explain consequence clearly in Permission Guard; re-prompt from Settings |
| `flutter_local_notifications` version breaking changes | Low | Medium | Pin package version; read changelog before upgrading |
| Timezone bugs (DST, travel) | Medium | Medium | Always store times in UTC; use `timezone` package for local display conversion |

---

*Generated for CriticalAlert v1.0 planning. Last updated: June 2026.*