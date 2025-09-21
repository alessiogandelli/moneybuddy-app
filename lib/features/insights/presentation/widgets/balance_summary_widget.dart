import 'package:flutter/material.dart';
import '../../../../core/theme/style.dart';
import '../../../../data/services/insights_service.dart';

/// Prominent balance display widget showing current financial position
/// Displays total balance, income vs expenses breakdown with visual indicators
class BalanceSummaryWidget extends StatelessWidget {
  final SpendingSummary? summary;

  const BalanceSummaryWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 32),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //_buildHeader(),
          _buildMainBalance(),

          _buildIncomeExpenseBreakdown(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        const Text(
          'Your Balance',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
          child: Text(
            _getBalanceStatus(),
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildMainBalance() {
    final balance = _getCurrentBalance();
    final isPositive = balance >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cash Flow',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
              children: [
                TextSpan(
                text: '${isPositive ? '' : '-'}${_formatCurrency(balance.abs())}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
                ),
                TextSpan(
                text: ' CHF',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
                ),
              ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: isPositive ? Colors.lightGreenAccent : Colors.redAccent,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseBreakdown() {
    final income = summary?.totalIncome ?? 0.0;
    final expenses = summary?.totalExpenses ?? 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Income
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: _formatCurrency(income),
                        style: const TextStyle(
                          color: Colors.lightGreenAccent,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      TextSpan(
                        text: ' CHF',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.lightGreenAccent,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Expenses
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Expenses',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: _formatCurrency(expenses),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      TextSpan(
                        text: ' CHF',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_down_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Helper methods
  double _getCurrentBalance() {
    if (summary == null) return 0.0;
    return summary!.totalIncome - summary!.totalExpenses;
  }

  String _getBalanceStatus() {
    final balance = _getCurrentBalance();
    if (balance > 1000) return 'Healthy';
    if (balance > 0) return 'Stable';
    if (balance > -500) return 'Caution';
    return 'Critical';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}
