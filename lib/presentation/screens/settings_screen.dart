import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _snoozeLimit = 3;
  bool _hapticFeedback = true;
  bool _notificationsPermission = false; // Mocked permission state
  bool _criticalAlertsOverride = true;

  void _incrementSnooze() {
    if (_snoozeLimit < 10) {
      setState(() {
        _snoozeLimit++;
      });
    }
  }

  void _decrementSnooze() {
    if (_snoozeLimit > 1) {
      setState(() {
        _snoozeLimit--;
      });
    }
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('Reset Settings?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will restore all default alarm behaviors and preferences.',
          style: TextStyle(color: Color(0xFF8E8E93)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E8E93))),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _snoozeLimit = 3;
                _hapticFeedback = true;
                _notificationsPermission = false;
                _criticalAlertsOverride = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to default'),
                  backgroundColor: Color(0xFF2C2C2E),
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Color(0xFFFF3B30))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Permissions Section
          _buildSectionHeader('Permissions'),
          _buildCard([
            // Notifications status
            _buildSettingRow(
              icon: _notificationsPermission ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
              iconColor: _notificationsPermission ? const Color(0xFF4CD964) : const Color(0xFFFF3B30),
              title: 'Notifications',
              trailing: Switch(
                value: _notificationsPermission,
                onChanged: (val) {
                  setState(() {
                    _notificationsPermission = val;
                  });
                },
                activeThumbColor: const Color(0xFF4CD964),
                activeTrackColor: const Color(0xFF4CD964).withValues(alpha: 0.3),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFF48484A),
              ),
              showDivider: true,
            ),
            // Critical Alerts Override
            _buildSettingRow(
              icon: _criticalAlertsOverride ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
              iconColor: _criticalAlertsOverride ? const Color(0xFF4CD964) : const Color(0xFF8E8E93),
              title: 'Critical Alerts Override',
              trailing: Switch(
                value: _criticalAlertsOverride,
                onChanged: (val) {
                  setState(() {
                    _criticalAlertsOverride = val;
                  });
                },
                activeThumbColor: const Color(0xFF4CD964),
                activeTrackColor: const Color(0xFF4CD964).withValues(alpha: 0.3),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFF48484A),
              ),
              showDivider: false,
            ),
          ]),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Prio requires notification permissions to ensure you never miss a critical reminder. Overriding Do Not Disturb ensures alarms sound when necessary.',
              style: TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Alarm Behavior Section
          _buildSectionHeader('Alarm Behavior'),
          _buildCard([
            // Default Alarm Sound
            _buildSettingRow(
              icon: Icons.music_note,
              iconColor: const Color(0xFFFF9F0A), // ios-orange
              title: 'Default alarm sound',
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Radar',
                    style: TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Color(0xFF8E8E93), size: 20),
                ],
              ),
              showDivider: true,
            ),
            // Snooze Limit Counter
            _buildSettingRow(
              icon: Icons.alarm,
              iconColor: const Color(0xFF007AFF),
              title: 'Snooze limit',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_snoozeLimit times',
                    style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _decrementSnooze,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Icon(Icons.remove, color: Colors.white, size: 16),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 16,
                          color: const Color(0x1AFFFFFF),
                        ),
                        GestureDetector(
                          onTap: _incrementSnooze,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Icon(Icons.add, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              showDivider: true,
            ),
            // Haptic Feedback Switch
            _buildSettingRow(
              icon: Icons.vibration,
              iconColor: const Color(0xFF5856D6), // iOS purple
              title: 'Haptic Feedback',
              trailing: Switch(
                value: _hapticFeedback,
                onChanged: (val) {
                  setState(() {
                    _hapticFeedback = val;
                  });
                },
                activeThumbColor: const Color(0xFF4CD964),
                activeTrackColor: const Color(0xFF4CD964).withValues(alpha: 0.3),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFF48484A),
              ),
              showDivider: false,
            ),
          ]),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About'),
          _buildCard([
            // What is Prio?
            _buildSettingRow(
              icon: Icons.info_outline,
              iconColor: const Color(0xFF8E8E93),
              title: 'What is Prio?',
              trailing: const Icon(Icons.chevron_right, color: Color(0xFF8E8E93), size: 20),
              showDivider: true,
            ),
            // App Version
            _buildSettingRow(
              icon: Icons.device_hub_outlined,
              iconColor: const Color(0xFF8E8E93),
              title: 'App Version',
              trailing: const Text(
                '2.1.4 (842)',
                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
              ),
              showDivider: false,
            ),
          ]),
          const SizedBox(height: 24),

          // Reset Settings Button
          Center(
            child: TextButton(
              onPressed: _resetSettings,
              child: const Text(
                'Reset All Settings',
                style: TextStyle(
                  color: Color(0xFFFF3B30),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 80), // extra padding for bottom bar
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF8E8E93),
          letterSpacing: 0.06,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E), // ios-card
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
    bool showDivider = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: showDivider
              ? const BorderSide(color: Color(0x1AFFFFFF), width: 0.5)
              : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}
