import 'package:flutter/material.dart';
import '../models/transaction.dart';

/// Service for calculating financial insights from transaction data
class InsightsService {
  
  /// Calculate spending summary from transactions
  static SpendingSummary calculateSpendingSummary(List<Transaction> transactions, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final filteredTransactions = _filterTransactionsByDate(transactions, startDate, endDate);
    
    double totalIncome = 0.0;
    double totalExpenses = 0.0;
    
    for (final transaction in filteredTransactions) {
      final direction = transaction.direction.toLowerCase();
      
      if (direction == 'credit' || direction == 'in') {
        totalIncome += transaction.amount.abs();
      } else if (direction == 'debit' || direction == 'out') {
        totalExpenses += transaction.amount.abs();
      } else {
        // Use amount sign as fallback
        if (transaction.amount >= 0) {
          totalIncome += transaction.amount;
        } else {
          totalExpenses += transaction.amount.abs();
        }
      }
    }
    
    final savingsRate = totalIncome > 0 ? ((totalIncome - totalExpenses) / totalIncome * 100) : 0.0;
    
    return SpendingSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      savingsRate: savingsRate,
      transactionCount: filteredTransactions.length,
    );
  }
  
  /// Calculate category breakdown from transactions
  static List<CategoryData> calculateCategoryBreakdown(List<Transaction> transactions, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final filteredTransactions = _filterTransactionsByDate(transactions, startDate, endDate);
    final Map<String, double> categoryTotals = {};
    
    for (final transaction in filteredTransactions) {
      // Only include expenses (debits/outgoing)
      final direction = transaction.direction.toLowerCase();
      bool isExpense = false;
      
      if (direction == 'debit' || direction == 'out') {
        isExpense = true;
      } else if (direction != 'credit' && direction != 'in' && transaction.amount < 0) {
        isExpense = true;
      }
      
      if (isExpense) {
        final category = _categorizeTransaction(transaction);
        final amount = transaction.amount.abs();
        categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
      }
    }
    
    // Sort by amount descending and take top categories
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final colors = [
      const Color(0xFFFF9800), // Orange
      const Color(0xFF2196F3), // Blue  
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFFF44336), // Red
      const Color(0xFF4CAF50), // Green
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFF795548), // Brown
    ];
    
    return sortedCategories.take(8).map((entry) {
      final index = sortedCategories.indexOf(entry) % colors.length;
      return CategoryData(entry.key, entry.value, colors[index]);
    }).toList();
  }
  
  /// Generate AI-powered insights
  static List<InsightItem> generateInsights(List<Transaction> transactions, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final List<InsightItem> insights = [];
    final filteredTransactions = _filterTransactionsByDate(transactions, startDate, endDate);
    
    if (filteredTransactions.isEmpty) {
      insights.add(InsightItem(
        emoji: '📊',
        title: 'Getting Started',
        description: 'Add some transactions to see personalized insights!',
        color: const Color(0xFF2196F3),
      ));
      return insights;
    }
    
    final summary = calculateSpendingSummary(transactions, startDate: startDate, endDate: endDate);
    final categories = calculateCategoryBreakdown(transactions, startDate: startDate, endDate: endDate);
    
    // Savings rate insight
    if (summary.savingsRate > 70) {
      insights.add(InsightItem(
        emoji: '🎯',
        title: 'Excellent savings!',
        description: 'You\'re saving ${summary.savingsRate.toStringAsFixed(1)}% of your income. You\'re on track for financial success!',
        color: const Color(0xFF4CAF50),
      ));
    } else if (summary.savingsRate > 30) {
      insights.add(InsightItem(
        emoji: '👍',
        title: 'Good savings rate',
        description: 'You\'re saving ${summary.savingsRate.toStringAsFixed(1)}% of your income. Consider increasing it to 20% or more.',
        color: const Color(0xFF2196F3),
      ));
    } else if (summary.savingsRate > 0) {
      insights.add(InsightItem(
        emoji: '⚠️',
        title: 'Low savings rate',
        description: 'You\'re only saving ${summary.savingsRate.toStringAsFixed(1)}%. Try to reduce expenses or increase income.',
        color: const Color(0xFFFF9800),
      ));
    } else {
      insights.add(InsightItem(
        emoji: '🚨',
        title: 'Spending more than earning',
        description: 'Your expenses exceed your income. Review your budget and cut unnecessary costs.',
        color: const Color(0xFFF44336),
      ));
    }
    
    // Top spending category insight
    if (categories.isNotEmpty) {
      final topCategory = categories.first;
      final percentage = summary.totalExpenses > 0 ? (topCategory.amount / summary.totalExpenses * 100) : 0;
      
      if (percentage > 40) {
        insights.add(InsightItem(
          emoji: '📈',
          title: 'High spending in ${topCategory.name}',
          description: '${topCategory.name} accounts for ${percentage.toStringAsFixed(1)}% of your expenses. Consider ways to reduce this.',
          color: const Color(0xFFFF9800),
        ));
      } else {
        insights.add(InsightItem(
          emoji: '✅',
          title: 'Balanced spending',
          description: 'Your spending is well distributed across categories with ${topCategory.name} being the highest.',
          color: const Color(0xFF4CAF50),
        ));
      }
    }
    
    // Transaction frequency insight
    final daysInPeriod = _getDaysInPeriod(startDate, endDate);
    final avgTransactionsPerDay = filteredTransactions.length / daysInPeriod;
    
    if (avgTransactionsPerDay > 5) {
      insights.add(InsightItem(
        emoji: '💳',
        title: 'High transaction frequency',
        description: 'You make ${avgTransactionsPerDay.toStringAsFixed(1)} transactions per day. Consider consolidating purchases.',
        color: const Color(0xFF2196F3),
      ));
    }
    
    // Weekend vs weekday spending
    final weekendSpending = _calculateWeekendSpending(filteredTransactions);
    final weekdaySpending = summary.totalExpenses - weekendSpending;
    
    if (weekendSpending > weekdaySpending && weekendSpending > 0) {
      insights.add(InsightItem(
        emoji: '🎉',
        title: 'Weekend spender',
        description: 'You spend more on weekends. Plan weekend budgets to control leisure expenses.',
        color: const Color(0xFF9C27B0),
      ));
    }
    
    return insights.take(4).toList(); // Limit to top 4 insights
  }
  
  /// Filter transactions by date range
  static List<Transaction> _filterTransactionsByDate(
    List<Transaction> transactions, 
    DateTime? startDate, 
    DateTime? endDate
  ) {
    if (startDate == null && endDate == null) return transactions;
    
    return transactions.where((transaction) {
      final date = transaction.bookingDate ?? transaction.valueDate ?? transaction.createdAt;
      
      if (startDate != null && date.isBefore(startDate)) return false;
      if (endDate != null && date.isAfter(endDate.add(const Duration(days: 1)))) return false;
      
      return true;
    }).toList();
  }
  
  /// Categorize transaction based on merchant name and type
  static String _categorizeTransaction(Transaction transaction) {
    final merchant = (transaction.merchantName ?? '').toLowerCase();
    final type = (transaction.trxType ?? '').toLowerCase();
    
    // Food & Dining
    if (merchant.contains('restaurant') || 
        merchant.contains('cafe') || 
        merchant.contains('pizza') || 
        merchant.contains('food') ||
        merchant.contains('mcdonald') ||
        merchant.contains('starbucks') ||
        type.contains('dining') ||
        type.contains('restaurant')) {
      return 'Food & Dining';
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
      return 'Transportation';
    }
    
    // Shopping
    if (merchant.contains('amazon') || 
        merchant.contains('shop') || 
        merchant.contains('store') || 
        merchant.contains('mall') ||
        merchant.contains('target') ||
        merchant.contains('walmart') ||
        type.contains('purchase')) {
      return 'Shopping';
    }
    
    // Entertainment
    if (merchant.contains('netflix') || 
        merchant.contains('spotify') || 
        merchant.contains('cinema') || 
        merchant.contains('theater') ||
        merchant.contains('game') ||
        type.contains('entertainment')) {
      return 'Entertainment';
    }
    
    // Bills & Utilities
    if (merchant.contains('electric') || 
        merchant.contains('water') || 
        merchant.contains('internet') || 
        merchant.contains('phone') ||
        merchant.contains('utility') ||
        type.contains('bill') ||
        type.contains('utility')) {
      return 'Bills & Utilities';
    }
    
    // Healthcare
    if (merchant.contains('pharmacy') || 
        merchant.contains('hospital') || 
        merchant.contains('doctor') || 
        merchant.contains('medical') ||
        type.contains('medical')) {
      return 'Healthcare';
    }
    
    // ATM/Cash
    if (merchant.contains('atm') || 
        merchant.contains('cash') || 
        type.contains('withdrawal')) {
      return 'ATM/Cash';
    }
    
    // Default category
    return 'Other';
  }
  
  /// Calculate weekend spending
  static double _calculateWeekendSpending(List<Transaction> transactions) {
    double weekendSpending = 0.0;
    
    for (final transaction in transactions) {
      final date = transaction.bookingDate ?? transaction.valueDate ?? transaction.createdAt;
      final weekday = date.weekday;
      
      // Saturday = 6, Sunday = 7
      if (weekday == 6 || weekday == 7) {
        final direction = transaction.direction.toLowerCase();
        if (direction == 'debit' || direction == 'out' || 
            (direction != 'credit' && direction != 'in' && transaction.amount < 0)) {
          weekendSpending += transaction.amount.abs();
        }
      }
    }
    
    return weekendSpending;
  }
  
  /// Get number of days in period
  static double _getDaysInPeriod(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 30.0; // Default to 30 days
    }
    return endDate.difference(startDate).inDays.toDouble().abs().clamp(1.0, double.infinity);
  }
  
  /// Get date range for period
  static DateRange getDateRangeForPeriod(String period) {
    final now = DateTime.now();
    
    switch (period) {
      case 'This Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return DateRange(
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      
      case 'This Month':
        return DateRange(
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1)),
        );
      
      case 'Last 3 Months':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return DateRange(threeMonthsAgo, now);
      
      case 'This Year':
        return DateRange(
          DateTime(now.year, 1, 1),
          DateTime(now.year, 12, 31),
        );
      
      default:
        return DateRange(
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1)),
        );
    }
  }
}

/// Data models for insights
class SpendingSummary {
  final double totalIncome;
  final double totalExpenses;
  final double savingsRate;
  final int transactionCount;
  
  const SpendingSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.savingsRate,
    required this.transactionCount,
  });
  
  double get netSavings => totalIncome - totalExpenses;
}

class CategoryData {
  final String name;
  final double amount;
  final Color color;

  const CategoryData(this.name, this.amount, this.color);
}

class InsightItem {
  final String emoji;
  final String title;
  final String description;
  final Color color;
  
  const InsightItem({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}

class DateRange {
  final DateTime start;
  final DateTime end;
  
  const DateRange(this.start, this.end);
}