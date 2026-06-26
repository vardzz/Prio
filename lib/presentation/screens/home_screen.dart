import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/section_header.dart';
import '../widgets/reminder_card.dart';
import '../widgets/quick_add_bento.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // ios-bg
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 768;
          return isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context);
        },
      ),
    );
  }

  // --- DESKTOP LAYOUT ---
  Widget _buildDesktopLayout(BuildContext context) {
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
                const Text(
                  'Prio',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.37,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {},
                      splashRadius: 22,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C2C2E), // ios-card
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {},
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
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCriticalSection(),
                          const SizedBox(height: 24),
                          _buildTodaySection(),
                          const SizedBox(height: 24),
                          _buildUpcomingSection(),
                          const SizedBox(height: 24),
                          _buildLaterSection(),
                          const SizedBox(height: 24),
                          _buildCompletedSection(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Sidebar
                  const SizedBox(
                    width: 320,
                    child: QuickAddBento(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MOBILE LAYOUT ---
  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              // Mobile Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Prio',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.36,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar (Mobile only)
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100.0), // Safe area for floating bottom nav/FAB
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildCriticalSection(),
                      const SizedBox(height: 24),
                      _buildTodaySection(),
                      const SizedBox(height: 24),
                      _buildUpcomingSection(),
                      const SizedBox(height: 24),
                      _buildLaterSection(),
                      const SizedBox(height: 24),
                      _buildCompletedSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Floating Navigation Bar + Floating Action Button (FAB)
        Positioned(
          left: 16,
          bottom: 24,
          child: _buildFloatingBottomNav(),
        ),
        Positioned(
          right: 16,
          bottom: 24,
          child: _buildFloatingActionButton(),
        ),
      ],
    );
  }

  // --- FLOATING UI CONTROLS ---
  Widget _buildFloatingBottomNav() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 220,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E).withOpacity(0.8), // ios-card/80
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
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
                isActive: true,
              ),
              _buildNavButton(
                icon: Icons.settings,
                label: 'Settings',
                isActive: false,
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
  }) {
    return InkWell(
      onTap: () {},
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

  Widget _buildFloatingActionButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E).withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {},
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
  Widget _buildCriticalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Critical'),
        _buildRoundedContainer(
          children: const [
            ReminderCard(
              title: 'Take Heart Medication',
              subtitle: 'In 2 hours · Medication',
              leftBorderColor: Color(0xFFFF3B30), // ios-red
              showBottomDivider: true,
            ),
            ReminderCard(
              title: 'Finalize Quarterly Report',
              subtitle: 'Due at 5:00 PM · Work',
              leftBorderColor: Color(0xFFFF3B30),
              showBottomDivider: true,
            ),
            ReminderCard(
              title: 'Pick up kids from school',
              subtitle: 'Due at 3:15 PM · Personal',
              leftBorderColor: Color(0xFFFF3B30),
              showBottomDivider: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Today'),
        _buildRoundedContainer(
          children: const [
            ReminderCard(
              title: 'Vitamin D Supplement',
              subtitle: '8:00 AM',
              icon: Icons.medical_services_outlined,
              leadingDotColor: Color(0xFFFF9F0A), // ios-orange
              showBottomDivider: true,
            ),
            ReminderCard(
              title: 'Call Mom',
              subtitle: '12:30 PM',
              icon: Icons.push_pin_outlined,
              showBottomDivider: true,
            ),
            ReminderCard(
              title: 'Pay Internet Bill',
              subtitle: 'Anytime',
              icon: Icons.credit_card,
              showBottomDivider: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Upcoming'),
        Opacity(
          opacity: 0.9,
          child: _buildRoundedContainer(
            children: const [
              ReminderCard(
                title: 'Dentist Appointment',
                trailing: Text(
                  'Tomorrow',
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                ),
                showBottomDivider: true,
              ),
              ReminderCard(
                title: 'Car Maintenance',
                trailing: Text(
                  'Friday',
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                ),
                showBottomDivider: false,
              ),
            ],
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

  Widget _buildCompletedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Completed'),
        Opacity(
          opacity: 0.6,
          child: _buildRoundedContainer(
            children: const [
              ReminderCard(
                title: 'Buy Groceries',
                isCompleted: true,
                showBottomDivider: false,
              ),
            ],
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
