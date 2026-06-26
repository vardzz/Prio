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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 100.0), // Padding to clear floating navbar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Permissions Section
          _buildSectionHeader('Permissions'),
          _buildCard([
            // Notifications status
            _buildSettingRow(
              title: 'Notifications',
              trailing: Switch(
                value: _notificationsPermission,
                onChanged: (val) {
                  setState(() {
                    _notificationsPermission = val;
                  });
                },
                activeThumbColor: const Color(0xFF30D158), // ios green
                activeTrackColor: const Color(0xFF30D158).withValues(alpha: 0.3),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFF48484A),
              ),
              showDivider: true,
            ),
            // Critical Alerts Override
            _buildSettingRow(
              title: 'Critical Alerts Override',
              trailing: Switch(
                value: _criticalAlertsOverride,
                onChanged: (val) {
                  setState(() {
                    _criticalAlertsOverride = val;
                  });
                },
                activeThumbColor: const Color(0xFF30D158),
                activeTrackColor: const Color(0xFF30D158).withValues(alpha: 0.3),
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
                color: Color(0x99EBEBF5), // text-secondary (60%)
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
              title: 'Default alarm sound',
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Radar',
                    style: TextStyle(color: Color(0x99EBEBF5), fontSize: 15),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Color(0x4DEBEBF5), size: 20),
                ],
              ),
              showDivider: true,
            ),
            // Snooze Limit Counter
            _buildSettingRow(
              title: 'Snooze limit',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_snoozeLimit times',
                    style: const TextStyle(color: Color(0x99EBEBF5), fontSize: 15),
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
              title: 'Haptic Feedback',
              trailing: Switch(
                value: _hapticFeedback,
                onChanged: (val) {
                  setState(() {
                    _hapticFeedback = val;
                  });
                },
                activeThumbColor: const Color(0xFF30D158),
                activeTrackColor: const Color(0xFF30D158).withValues(alpha: 0.3),
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
              title: 'What is Prio?',
              trailing: const Icon(Icons.chevron_right, color: Color(0x4DEBEBF5), size: 20),
              showDivider: true,
            ),
            // App Version
            _buildSettingRow(
              title: 'App Version',
              trailing: const Text(
                '2.1.4 (842)',
                style: TextStyle(color: Color(0x99EBEBF5), fontSize: 15),
              ),
              showDivider: false,
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0x99EBEBF5), // text-secondary (60%)
          letterSpacing: 0.06,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E), // bg-surface (iOS grey)
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingRow({
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
