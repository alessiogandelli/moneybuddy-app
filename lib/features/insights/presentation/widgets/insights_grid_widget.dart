import 'package:flutter/material.dart';
import '../../../../core/theme/style.dart';
import '../../../../data/services/insights_service.dart';
import 'expanded_insight_view.dart';

/// Widget that displays AI-generated insights in a grid layout
/// Each insight is presented as a colorful card with emoji, title, and description
class InsightsGridWidget extends StatelessWidget {
  final List<InsightItem> insights;
  final int maxInsights;
  final int crossAxisCount;
  final double childAspectRatio;

  const InsightsGridWidget({
    super.key,
    required this.insights,
    this.maxInsights = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return _buildEmptyState();
    }

    final displayInsights = insights.take(maxInsights).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < displayInsights.length) {
              return _buildInsightCard(context, displayInsights[index], index);
            }
            return null;
          },
          childCount: displayInsights.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppStyle.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: Colors.white54,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'No insights available',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add some transactions to get personalized insights',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, InsightItem insight, int index) {
    final colors = _getCardColors();
    final cardColors = colors[0];//[index % colors.length];
    
    return GestureDetector(
      onTap: () => _openExpandedView(context, insight, cardColors),
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 100),
        child: Hero(
          tag: 'insight_${insight.title}',
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardColors[0].withOpacity(0.1),
                    cardColors[1].withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cardColors[0].withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInsightIcon(insight.emoji, cardColors[0]),
                  const SizedBox(height: 16),
                  _buildInsightTitle(insight.title),
                  const SizedBox(height: 8),
                  _buildInsightDescription(insight.description),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openExpandedView(BuildContext context, InsightItem insight, List<Color> cardColors) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ExpandedInsightView(
          insight: insight,
          cardColors: cardColors,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Only fade the background, let Hero handle the card scaling
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        opaque: false,
      ),
    );
  }

  Widget _buildInsightIcon(String emoji, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildInsightTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInsightDescription(String description) {
    return Expanded(
      child: Text(
        description,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 13,
          height: 1.4,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  List<List<Color>> _getCardColors() {
    return [
      [AppStyle.primaryGreen, AppStyle.greenAccent],
      [AppStyle.stateSuccess100, AppStyle.stateSuccess70], 
      [AppStyle.secondaryGlacier100, AppStyle.secondaryGlacier70],
      [AppStyle.primaryLight100, AppStyle.primaryLight70],
      [AppStyle.stateWarning100, AppStyle.stateWarning70],
      [AppStyle.primaryAir100, AppStyle.primaryAir70],
    ];
  }
}