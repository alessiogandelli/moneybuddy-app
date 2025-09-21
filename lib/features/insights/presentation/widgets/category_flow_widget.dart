import 'package:flutter/material.dart';
import '../../../../core/theme/style.dart';
import '../../../../data/services/insights_service.dart';

/// Widget that displays spending categories with visual progress bars
/// Shows where the user's money flows with color-coded categories and amounts
import 'dart:math' as math;

class CategoryFlowWidget extends StatelessWidget {
  final List<CategoryData> categories;
  final int maxCategoriesToShow;

  const CategoryFlowWidget({
    super.key,
    required this.categories,
    this.maxCategoriesToShow = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return _buildEmptyState();
    }

    final total = categories.fold<double>(0, (sum, c) => sum + c.amount);
    final top = categories.take(maxCategoriesToShow).toList();
    final othersAmount = categories.length > maxCategoriesToShow
        ? categories.skip(maxCategoriesToShow).fold<double>(0, (s, c) => s + c.amount)
        : 0.0;

    final slices = <_Slice>[
      ...top.map((c) => _Slice(name: c.name, amount: c.amount, color: c.color)),
      if (othersAmount > 0)
        _Slice(name: 'Others', amount: othersAmount, color: Colors.white24),
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _DonutChart(
                    slices: slices,
                    total: total,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 6,
                child: _buildLegend(slices),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [

        const SizedBox(width: 16),
        const Text(
          'Where Your Money Flows',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.pie_chart_outline_rounded,
                  color: Colors.white54,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'No spending data available',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add some transactions to see category breakdown',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(List<_Slice> slices) {
    final total = slices.fold<double>(0, (sum, x) => sum + x.amount);
    return Column(
      children: slices.map((s) {
        final percent = total == 0 ? 0 : (s.amount / total * 100).round();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: s.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DonutChart extends StatelessWidget {
  final List<_Slice> slices;
  final double total;

  const _DonutChart({
    required this.slices,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final t = total <= 0 ? 0.0 : total;
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          painter: _DonutPainter(
            slices: slices,
            total: t,
            trackColor: Colors.white.withOpacity(0.08),
            strokeWidth: 22,
          ),
          child: const SizedBox.expand(),
        ),
        // Center intentionally left blank (no totals or amounts)
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<_Slice> slices;
  final double total;
  final double strokeWidth;
  final Color trackColor;

  _DonutPainter({
    required this.slices,
    required this.total,
    required this.strokeWidth,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (total <= 0) return;

    var startAngle = -math.pi / 2;
    for (final s in slices) {
      if (s.amount <= 0) continue;
      final sweep = (s.amount / total) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = s.color
        ..strokeCap = StrokeCap.butt;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.total != total ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor;
    }
}

class _Slice {
  final String name;
  final double amount;
  final Color color;

  _Slice({
    required this.name,
    required this.amount,
    required this.color,
  });
}
