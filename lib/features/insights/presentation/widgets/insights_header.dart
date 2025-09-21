import 'package:flutter/material.dart';
import '../../../../core/theme/style.dart';
import '../../../../data/services/insights_service.dart';
import 'balance_indicator.dart';

/// Hero section widget for the insights screen containing financial health status,
/// main story title/subtitle, and balance indicators for Net Flow and Savings Rate
class InsightsHeaderWidget extends StatelessWidget {
  final SpendingSummary? summary;
  final String Function() getFinancialHealthStatus;
  final String Function() getMainStoryTitle;  
  final String Function() getMainStorySubtitle;

  const InsightsHeaderWidget({
    super.key,
    required this.summary,
    required this.getFinancialHealthStatus,
    required this.getMainStoryTitle,
    required this.getMainStorySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppStyle.primaryGreen.withOpacity(0.8),
            AppStyle.greenAccent.withOpacity(0.6),
            AppStyle.stateSuccess70.withOpacity(0.4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppStyle.primaryGreen.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated background pattern

          // Hero content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Financial health indicator
                
                _buildFinancialHealthIndicator(),
                const SizedBox(height: 12),
                // Main story
                _buildMainStory(),
              
                // Interactive balance display
               // _buildBalanceRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialHealthIndicator() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 239, 114, 25).withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
              getFinancialHealthStatus().toLowerCase().contains('attention')
                ? Icons.warning_amber_rounded
                : Icons.trending_up_rounded,
              color: getFinancialHealthStatus().toLowerCase().contains('attention')
                ? Colors.amber
                : Colors.greenAccent,
              size: 20,
              ),
              const SizedBox(width: 8),
              Text(
              getFinancialHealthStatus(),
              style: TextStyle(
                color:
                   Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainStory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getMainStoryTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          getMainStorySubtitle(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceRow() {
    return Row(
      children: [
        Expanded(
          child: BalanceIndicator(
            label: 'Net Flow',
            value: summary?.totalIncome != null
              ? '\$${((summary!.totalIncome - summary!.totalExpenses) / 1000).toStringAsFixed(1)}k'
              : '\$0',
            color: summary != null && summary!.totalIncome > summary!.totalExpenses 
              ? Colors.greenAccent 
              : Colors.redAccent,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: BalanceIndicator(
            label: 'Savings Rate',
            value: summary?.savingsRate != null 
              ? '${summary!.savingsRate.toStringAsFixed(1)}%'
              : '0%',
            color: Colors.cyanAccent,
          ),
        ),
      ],
    );
  }
}