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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left border indicator (for Critical tasks)
                if (leftBorderColor != null) ...[
                  Container(
                    width: 4,
                    height: 20,
                    color: leftBorderColor,
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  const SizedBox(width: 16),
                ],

                // Priority dot, checked state, or icon
                if (isCompleted) ...[
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF30D158), // accent-completed (iOS green)
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                ] else if (leadingDotColor != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0), // Align to cap-height of title
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: leadingDotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    color: const Color(0x4DEBEBF5), // text-tertiary (30%)
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                ],

                // Title and Subtitles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: isCompleted
                              ? const Color(0x4DEBEBF5) // text-tertiary (30%)
                              : Colors.white,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          height: 1.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0x99EBEBF5), // text-secondary (60%)
                            height: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing Widget
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
          if (showBottomDivider)
            Padding(
              padding: const EdgeInsets.only(left: 36.0), // Inset to align with text start
              child: Container(
                height: 0.5,
                color: const Color(0xFF3A3A3C), // divider token
              ),
            ),
        ],
      ),
    );
  }
}
