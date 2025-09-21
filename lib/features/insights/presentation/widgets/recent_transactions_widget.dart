import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/style.dart';
import '../../../../data/models/transaction.dart';

/// Widget that displays a list of recent transactions with navigation to detailed views
/// Includes add transaction button and empty state handling
class RecentTransactionsWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final int maxTransactions;

  const RecentTransactionsWidget({
    super.key,
    required this.transactions,
    this.maxTransactions = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 28),
          _buildTransactionsList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.push('/transactions');
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.blue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 18),
                const Expanded(
                  child: Text(
                    'Recent\nTransactions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.6),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
       
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/transactions/add');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    final displayTransactions = transactions.take(2).toList();

    return Column(
      children: displayTransactions.map((transaction) {
        return GestureDetector(
          onTap: () {
            context.push('/transactions/${transaction.trxId}');
          },
          child: _buildTransactionItem(transaction),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_outlined,
              color: Colors.white54,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'No recent transactions',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
            Text(
              'Add your first transaction to get started',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final category = _getCategoryForTransaction(transaction);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Transaction type indicator (vertical line)
          Container(
            width: 6,
            height: 48,
            decoration: BoxDecoration(
              color: _getTransactionColor(transaction),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 16),

          // Transaction details (give it more room and allow 2 lines)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.merchantName ??
                      transaction.merchantFullText ??
                      'Transaction',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDate(
                    transaction.bookingDate ??
                        transaction.valueDate ??
                        DateTime.now(),
                  ),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Trailing info (constrained to avoid cutting the title too much)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Amount
                Text(
                  '${transaction.direction == 'OUT' ? '-' : ''}€${transaction.amount.abs().toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _getTransactionColor(transaction),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                // Category chip (ellipsis if too long)
                Container(
                  constraints: const BoxConstraints(maxWidth: 140),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTransactionColor(transaction).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCategoryDisplayName(category),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _getTransactionColor(transaction),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.4),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTransactionColor(Transaction transaction) {
    final direction = transaction.direction;
    if (direction == 'IN') return AppStyle.greenAccent;
    if (direction == 'OUT') return AppStyle.stateError100;
    return Colors.grey;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference} days ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get category for transaction using smart categorization
  String _getCategoryForTransaction(Transaction transaction) {
    final merchant = (transaction.merchantName ?? '').toLowerCase();
    final type = (transaction.trxType ?? '').toLowerCase();
    
    // Food & Dining
    if (merchant.contains('restaurant') || 
        merchant.contains('cafe') || 
        merchant.contains('pizza') || 
        merchant.contains('food') ||
        merchant.contains('mcdonald') ||
        merchant.contains('starbucks') ||
        merchant.contains('lenzerhei') || // From your UI mockup
        type.contains('dining') ||
        type.contains('restaurant')) {
      return 'food';
    }
    
    // Transportation
    if (merchant.contains('uber') || 
        merchant.contains('lyft') || 
        merchant.contains('taxi') || 
        merchant.contains('gas') ||
        merchant.contains('fuel') ||
        merchant.contains('metro') ||
        merchant.contains('bus') ||
        type.contains('transport')) {
      return 'transport';
    }
    
    // Shopping
    if (merchant.contains('amazon') || 
        merchant.contains('shop') || 
        merchant.contains('store') || 
        merchant.contains('mall') ||
        merchant.contains('target') ||
        merchant.contains('walmart') ||
        merchant.contains('kantine') || // From your UI mockup
        type.contains('purchase')) {
      return 'shopping';
    }
    
    // Card transactions
    if (type.contains('card') || transaction.trxType == 'cardtrx') {
      return 'card';
    }
    
    // Payment transactions
    if (type.contains('pay') || transaction.trxType == 'pay') {
      return 'payment';
    }
    
    // Default
    return 'other';
  }

  /// Get category display name
  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'food':
        return 'Food & Dining';
      case 'transport':
        return 'Transportation';
      case 'shopping':
        return 'Shopping';
      case 'card':
        return 'cardtrx';
      case 'payment':
        return 'pay';
      default:
        return 'Other';
    }
  }
}