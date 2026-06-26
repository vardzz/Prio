import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../data/models/reminder.dart';
import '../widgets/section_header.dart';
import '../widgets/reminder_card.dart';
import '../widgets/quick_add_bento.dart';
import '../widgets/add_reminder_dialog.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // --- PRESELECTION FOR BENTO ---
  void _openAddReminder(BuildContext context, WidgetRef ref, {ReminderType? type}) async {
    final result = await showDialog<Reminder>(
      context: context,
      builder: (context) => AddReminderDialog(initialType: type),
    );

    if (result != null) {
      ref.read(reminderListProvider.notifier).addReminder(result);
    }
  }

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  bool _isUpcoming(DateTime dt) {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return dt.isAfter(todayEnd);
  }

  String _getSubtitle(Reminder r) {
    final now = DateTime.now();
    final diff = r.scheduledAt.difference(now);
    String timeStr = '';
    
    if (diff.inMinutes > 0 && diff.inHours < 12) {
      if (diff.inHours > 0) {
        timeStr = 'In ${diff.inHours} hour${diff.inHours > 1 ? 's' : ''}';
      } else {
        timeStr = 'In ${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''}';
      }
    } else {
      final hour = r.scheduledAt.hour > 12 ? r.scheduledAt.hour - 12 : (r.scheduledAt.hour == 0 ? 12 : r.scheduledAt.hour);
      final ampm = r.scheduledAt.hour >= 12 ? 'PM' : 'AM';
      final min = r.scheduledAt.minute.toString().padLeft(2, '0');
      timeStr = 'Due at $hour:$min $ampm';
    }

    final typeName = r.type.name[0].toUpperCase() + r.type.name.substring(1);
    return '$timeStr · $typeName';
  }

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return Icons.medical_services_outlined;
      case ReminderType.deadline:
        return Icons.push_pin_outlined;
      case ReminderType.bill:
        return Icons.credit_card;
      case ReminderType.custom:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReminders = ref.watch(reminderListProvider);
    final activeTab = ref.watch(navigationProvider);

    // Partition reminders
    final critical = allReminders.where((r) => r.priority == PriorityLevel.critical && !r.isCompleted).toList();
    final today = allReminders.where((r) => r.priority != PriorityLevel.critical && !r.isCompleted && _isToday(r.scheduledAt)).toList();
    final upcoming = allReminders.where((r) => r.priority != PriorityLevel.critical && !r.isCompleted && _isUpcoming(r.scheduledAt)).toList();
    final completed = allReminders.where((r) => r.isCompleted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // ios-bg
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 768;
          return isDesktop 
              ? _buildDesktopLayout(context, ref, activeTab, critical, today, upcoming, completed) 
              : _buildMobileLayout(context, ref, activeTab, critical, today, upcoming, completed);
        },
      ),
    );
  }

  // --- DESKTOP LAYOUT ---
  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    int activeTab,
    List<Reminder> critical,
    List<Reminder> today,
    List<Reminder> upcoming,
    List<Reminder> completed,
  ) {
    return SafeArea(
      child: Column(
        children: [
          // Desktop Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  activeTab == 0 ? 'prio' : 'settings',
                  style: GoogleFonts.anton(
                    textStyle: const TextStyle(
                      fontSize: 34,
                      color: Colors.white,
                      letterSpacing: 0.37,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (activeTab == 0) ...[
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {},
                        splashRadius: 22,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C2C2E), // ios-card
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () => _openAddReminder(context, ref),
                        splashRadius: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Main Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Content
                  Expanded(
                    flex: 2,
                    child: activeTab == 0
                        ? SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCriticalSection(ref, critical),
                                const SizedBox(height: 24),
                                _buildTodaySection(ref, today),
                                const SizedBox(height: 24),
                                _buildUpcomingSection(ref, upcoming),
                                const SizedBox(height: 24),
                                _buildLaterSection(),
                                const SizedBox(height: 24),
                                _buildCompletedSection(ref, completed),
                                const SizedBox(height: 40),
                              ],
                            ),
                          )
                        : const SettingsScreen(),
                  ),
                  const SizedBox(width: 32),
                  // Sidebar (Keep on desktop for quick actions, or only show if activeTab == 0)
                  if (activeTab == 0)
                    SizedBox(
                      width: 320,
                      child: QuickAddBento(
                        onCategoryTap: (category) {
                          ReminderType? type;
                          if (category == 'Groceries') type = ReminderType.custom;
                          if (category == 'Work') type = ReminderType.deadline;
                          if (category == 'Health') type = ReminderType.medication;
                          if (category == 'Custom') type = ReminderType.custom;
                          _openAddReminder(context, ref, type: type);
                        },
                      ),
                    )
                  else
                    const SizedBox(width: 320), // Placeholder to maintain centered layout grid alignment
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MOBILE LAYOUT ---
  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    int activeTab,
    List<Reminder> critical,
    List<Reminder> today,
    List<Reminder> upcoming,
    List<Reminder> completed,
  ) {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              // Mobile Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      activeTab == 0 ? 'prio' : 'settings',
                      style: GoogleFonts.anton(
                        textStyle: const TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          letterSpacing: 0.36,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar (Mobile only, only show on Reminders tab)
              if (activeTab == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E), // ios-card
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 12),
                        Icon(Icons.search, color: Color(0xFF8E8E93)),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            style: TextStyle(color: Colors.white, fontSize: 17),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search reminders',
                              hintStyle: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 17,
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Scrollable content
              Expanded(
                child: activeTab == 0
                    ? SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 100.0), // Safe area for floating bottom nav/FAB
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildCriticalSection(ref, critical),
                            const SizedBox(height: 24),
                            _buildTodaySection(ref, today),
                            const SizedBox(height: 24),
                            _buildUpcomingSection(ref, upcoming),
                            const SizedBox(height: 24),
                            _buildLaterSection(),
                            const SizedBox(height: 24),
                            _buildCompletedSection(ref, completed),
                          ],
                        ),
                      )
                    : const SettingsScreen(),
              ),
            ],
          ),
        ),

        // Floating Navigation Bar + Floating Action Button (FAB)
        Positioned(
          left: 16,
          bottom: 24,
          child: _buildFloatingBottomNav(ref, activeTab),
        ),
        if (activeTab == 0) // Only show FAB on reminders tab since Settings has header '+' button
          Positioned(
            right: 16,
            bottom: 24,
            child: _buildFloatingActionButton(context, ref),
          ),
      ],
    );
  }

  // --- FLOATING UI CONTROLS ---
  Widget _buildFloatingBottomNav(WidgetRef ref, int activeTab) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 220,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E).withValues(alpha: 0.8), // ios-card/80
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavButton(
                icon: Icons.notifications,
                label: 'Reminders',
                isActive: activeTab == 0,
                onTap: () => ref.read(navigationProvider.notifier).state = 0,
              ),
              _buildNavButton(
                icon: Icons.settings,
                label: 'Settings',
                isActive: activeTab == 1,
                onTap: () => ref.read(navigationProvider.notifier).state = 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : const Color(0xFF8E8E93),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: isActive ? Colors.white : const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E).withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _openAddReminder(context, ref),
            customBorder: const CircleBorder(),
            child: const Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- SECTIONS ---
  Widget _buildCriticalSection(WidgetRef ref, List<Reminder> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Critical'),
        _buildRoundedContainer(
          children: List.generate(items.length, (idx) {
            final r = items[idx];
            return ReminderCard(
              title: r.title,
              subtitle: _getSubtitle(r),
              leftBorderColor: const Color(0xFFFF3B30), // ios-red
              showBottomDivider: idx < items.length - 1,
              onTap: () {
                ref.read(reminderListProvider.notifier).updateReminder(
                      r.copyWith(isCompleted: !r.isCompleted),
                    );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTodaySection(WidgetRef ref, List<Reminder> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Today'),
        _buildRoundedContainer(
          children: List.generate(items.length, (idx) {
            final r = items[idx];
            Color? dotColor;
            if (r.priority == PriorityLevel.high) {
              dotColor = const Color(0xFFFF9F0A);
            } else if (r.priority == PriorityLevel.critical) {
              dotColor = const Color(0xFFFF3B30);
            }
            return ReminderCard(
              title: r.title,
              subtitle: r.description ?? _getSubtitle(r),
              icon: _getTypeIcon(r.type),
              leadingDotColor: dotColor,
              showBottomDivider: idx < items.length - 1,
              onTap: () {
                ref.read(reminderListProvider.notifier).updateReminder(
                      r.copyWith(isCompleted: !r.isCompleted),
                    );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildUpcomingSection(WidgetRef ref, List<Reminder> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Upcoming'),
        Opacity(
          opacity: 0.9,
          child: _buildRoundedContainer(
            children: List.generate(items.length, (idx) {
              final r = items[idx];
              final dateLabel = '${r.scheduledAt.month}/${r.scheduledAt.day}';
              return ReminderCard(
                title: r.title,
                trailing: Text(
                  dateLabel,
                  style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                ),
                showBottomDivider: idx < items.length - 1,
                onTap: () {
                  ref.read(reminderListProvider.notifier).updateReminder(
                        r.copyWith(isCompleted: !r.isCompleted),
                      );
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildLaterSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Later',
          trailing: Icon(
            Icons.expand_more,
            color: Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedSection(WidgetRef ref, List<Reminder> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Completed'),
        Opacity(
          opacity: 0.6,
          child: _buildRoundedContainer(
            children: List.generate(items.length, (idx) {
              final r = items[idx];
              return ReminderCard(
                title: r.title,
                isCompleted: true,
                showBottomDivider: idx < items.length - 1,
                onTap: () {
                  ref.read(reminderListProvider.notifier).updateReminder(
                        r.copyWith(isCompleted: !r.isCompleted),
                      );
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildRoundedContainer({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E), // ios-card
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
