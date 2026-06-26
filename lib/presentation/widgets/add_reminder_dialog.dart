import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/reminder.dart';

class AddReminderDialog extends StatefulWidget {
  final ReminderType? initialType;
  const AddReminderDialog({super.key, this.initialType});

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  late ReminderType _selectedType;
  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 2));
  RepeatInterval? _selectedRepeat;
  PriorityLevel _selectedPriority = PriorityLevel.critical;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? ReminderType.medication;
    // Default Medication type auto-sets to CRITICAL priority
    if (_selectedType == ReminderType.medication) {
      _selectedPriority = PriorityLevel.critical;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onTypeChanged(ReminderType type) {
    setState(() {
      _selectedType = type;
      if (type == ReminderType.medication) {
        _selectedPriority = PriorityLevel.critical;
      }
    });
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF3B30), // ios-red
              onPrimary: Colors.white,
              surface: Color(0xFF2C2C2E), // ios-card
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1C1C1E)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFFF3B30),
                onPrimary: Colors.white,
                surface: Color(0xFF2C2C2E),
                onSurface: Colors.white,
              ),
              dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1C1C1E)),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _selectRepeat() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Select Repeat Interval',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
              const Divider(color: Color(0x1AFFFFFF), height: 1),
              _buildRepeatTile(null, 'None'),
              _buildRepeatTile(RepeatInterval.everyTwelveHours, 'Every 12h'),
              _buildRepeatTile(RepeatInterval.daily, 'Daily'),
              _buildRepeatTile(RepeatInterval.weekly, 'Weekly'),
              _buildRepeatTile(RepeatInterval.monthly, 'Monthly'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRepeatTile(RepeatInterval? val, String label) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: _selectedRepeat == val
          ? const Icon(Icons.check, color: Color(0xFFFF3B30))
          : null,
      onTap: () {
        setState(() {
          _selectedRepeat = val;
        });
        Navigator.pop(context);
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final inputDate = DateTime(dt.year, dt.month, dt.day);

    String dateStr = '';
    if (today == inputDate) {
      dateStr = 'Today';
    } else if (today.add(const Duration(days: 1)) == inputDate) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dt.month}/${dt.day}/${dt.year}';
    }

    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');

    return '$dateStr, $hour:$minuteStr $ampm';
  }

  String _getRepeatLabel(RepeatInterval? ri) {
    if (ri == null) return 'None';
    switch (ri) {
      case RepeatInterval.everyFourHours:
        return 'Every 4h';
      case RepeatInterval.everySixHours:
        return 'Every 6h';
      case RepeatInterval.everyEightHours:
        return 'Every 8h';
      case RepeatInterval.everyTwelveHours:
        return 'Every 12h';
      case RepeatInterval.daily:
        return 'Daily';
      case RepeatInterval.weekly:
        return 'Weekly';
      case RepeatInterval.monthly:
        return 'Monthly';
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Color(0xFFFF3B30),
        ),
      );
      return;
    }

    final newReminder = Reminder(
      id: const Uuid().v4(),
      title: title,
      description: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      type: _selectedType,
      scheduledAt: _selectedDateTime,
      repeat: _selectedRepeat,
      priority: _selectedPriority,
      isCompleted: false,
    );

    Navigator.pop(context, newReminder);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Dialog(
      backgroundColor: const Color(0xFF1C1C1E), // ios-bg
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog header / Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'What do you need to do?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF8E8E93)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title input text field
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontSize: 17),
                decoration: const InputDecoration(
                  hintText: 'e.g. Take heart meds, Finalize report',
                  hintStyle: TextStyle(color: Color(0xFF8E8E93)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0x1AFFFFFF)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF3B30)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Reminder Type Pills Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTypePill(ReminderType.medication, Icons.medical_services_outlined, 'Medication'),
                    const SizedBox(width: 8),
                    _buildTypePill(ReminderType.deadline, Icons.push_pin_outlined, 'Deadline'),
                    const SizedBox(width: 8),
                    _buildTypePill(ReminderType.bill, Icons.credit_card, 'Bill'),
                    const SizedBox(width: 8),
                    _buildTypePill(ReminderType.custom, Icons.more_horiz, 'Custom'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Medication auto-set warning notice
              if (_selectedType == ReminderType.medication)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: Color(0xFFFF3B30)),
                      SizedBox(width: 6),
                      Text(
                        'Auto-set to CRITICAL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF3B30), // ios-red
                        ),
                      ),
                    ],
                  ),
                ),

              // Settings Container (Card style)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E), // ios-card
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Date & Time Select Tile
                    _buildInteractiveSettingTile(
                      icon: Icons.calendar_month,
                      iconColor: const Color(0xFFFF9F0A),
                      label: 'Date & Time',
                      value: _formatDateTime(_selectedDateTime),
                      onTap: _selectDateTime,
                      showDivider: true,
                    ),

                    // Repeat Select Tile
                    _buildInteractiveSettingTile(
                      icon: Icons.access_time,
                      iconColor: const Color(0xFF8E8E93),
                      label: 'Repeat',
                      value: _formatDateTime(_selectedDateTime) != _getRepeatLabel(_selectedRepeat)
                          ? _getRepeatLabel(_selectedRepeat)
                          : '',
                      onTap: _selectRepeat,
                      showDivider: true,
                    ),

                    // Priority Tile
                    _buildPrioritySettingTile(),

                    // Notes Text Field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notes, color: Color(0xFF8E8E93), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _notesController,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              maxLines: 2,
                              decoration: const InputDecoration(
                                hintText: 'Add notes (e.g., take with food)',
                                hintStyle: TextStyle(color: Color(0xFF8E8E93)),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30), // ios-red
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'Schedule Reminder',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypePill(ReminderType type, IconData icon, String label) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () => _onTypeChanged(type),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x33FF3B30) : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF3B30) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? const Color(0xFFFF3B30) : const Color(0xFF8E8E93),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFFFF3B30) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveSettingTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w400),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Color(0xFF8E8E93), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySettingTile() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x1AFFFFFF), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag_outlined, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                'Priority',
                style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildPrioritySegment(PriorityLevel.critical, 'Critical', const Color(0xFFFF3B30)),
                _buildPrioritySegment(PriorityLevel.high, 'High', const Color(0xFFFF9F0A)),
                _buildPrioritySegment(PriorityLevel.normal, 'Normal', Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySegment(PriorityLevel level, String label, Color dotColor) {
    final isSelected = _selectedPriority == level;
    final isDisabled = _selectedType == ReminderType.medication && level != PriorityLevel.critical;

    return Expanded(
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                setState(() {
                  _selectedPriority = level;
                });
              },
        child: Opacity(
          opacity: isDisabled ? 0.3 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2C2C2E) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? Icons.circle : Icons.circle_outlined,
                  size: 8,
                  color: dotColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
