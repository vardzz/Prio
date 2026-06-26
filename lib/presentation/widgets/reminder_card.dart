import 'package:flutter/material.dart';

class ReminderCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? leadingDotColor;
  final Color? leftBorderColor;
  final bool isCompleted;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showBottomDivider;

  const ReminderCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leadingDotColor,
    this.leftBorderColor,
    this.isCompleted = false,
    this.trailing,
    this.onTap,
    this.showBottomDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: showBottomDivider
                ? const BorderSide(color: Color(0x1AFFFFFF), width: 0.5) // ios-divider
                : BorderSide.none,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left border indicator (for Critical tasks)
              if (leftBorderColor != null) ...[
                Container(
                  width: 4,
                  color: leftBorderColor,
                ),
                const SizedBox(width: 12),
              ] else ...[
                const SizedBox(width: 16),
              ],

              // Leading Dot/Indicator/Icon
              if (isCompleted) ...[
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF48484A), // ios-check
                  size: 20,
                ),
                const SizedBox(width: 12),
              ] else if (leadingDotColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: leadingDotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
              ] else if (icon != null) ...[
                Icon(
                  icon,
                  color: const Color(0xFF8E8E93), // ios-muted
                  size: 20,
                ),
                const SizedBox(width: 12),
              ],

              // Title and Subtitle
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: isCompleted || leftBorderColor != null
                              ? FontWeight.w600 // headline weight
                              : FontWeight.w400, // body weight
                          color: isCompleted
                              ? const Color(0xFF8E8E93) // ios-muted
                              : Colors.white,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8E8E93), // ios-muted
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Trailing widget
              if (trailing != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: trailing!,
                ),
              ] else ...[
                const SizedBox(width: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
