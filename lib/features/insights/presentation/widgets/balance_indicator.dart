import 'package:flutter/material.dart';

/// Reusable widget for displaying balance indicators with labels and values
/// Used in the insights hero section to show metrics like Net Flow and Savings Rate
class BalanceIndicator extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final bool isCompact;

  const BalanceIndicator({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.padding,
    this.fontSize,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: isCompact ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isCompact ? 2 : 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: fontSize ?? (isCompact ? 16 : 20),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}