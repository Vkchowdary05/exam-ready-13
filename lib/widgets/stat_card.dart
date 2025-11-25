// lib/widgets/stat_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/entry_theme.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;
  final int index;

  const StatCard({
    super.key,
    required this.icon,
    required this.number,
    required this.label,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final gradients = [
      AppTheme.primaryGradient,
      AppTheme.secondaryGradient,
      AppTheme.accentGradient,
      const LinearGradient(
        colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: gradients[index % gradients.length],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradients[index % gradients.length]
                .colors
                .first
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                icon,
                size: 100,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  Text(
                    number,
                    style: AppTheme.statNumberStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: AppTheme.statLabelStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: (100 * index).ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 600.ms,
          delay: (100 * index).ms,
          curve: Curves.easeOutBack,
        );
  }
}