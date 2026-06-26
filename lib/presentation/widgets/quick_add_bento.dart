import 'package:flutter/material.dart';

class QuickAddBento extends StatelessWidget {
  final Function(String category)? onCategoryTap;

  const QuickAddBento({
    super.key,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E), // ios-card
        borderRadius: BorderRadius.circular(12), // ios-card radius
      ),
      padding: const EdgeInsets.all(16.0), // margin-main spacing equivalent
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Add',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildBentoItem(
                icon: Icons.shopping_cart,
                label: 'Groceries',
                iconColor: const Color(0xFFFF9F0A), // ios-orange
                onTap: () => onCategoryTap?.call('Groceries'),
              ),
              _buildBentoItem(
                icon: Icons.work,
                label: 'Work',
                iconColor: const Color(0xFF1D9CC3), // tertiary-container color
                onTap: () => onCategoryTap?.call('Work'),
              ),
              _buildBentoItem(
                icon: Icons.local_pharmacy,
                label: 'Health',
                iconColor: const Color(0xFFFF3B30), // ios-red
                onTap: () => onCategoryTap?.call('Health'),
              ),
              _buildBentoItem(
                icon: Icons.more_horiz,
                label: 'Custom',
                iconColor: Colors.white,
                onTap: () => onCategoryTap?.call('Custom'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoItem({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E), // ios-bg
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
