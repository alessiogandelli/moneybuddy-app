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
  
  /// Detect recurring subscription payments
  static List<SubscriptionData> detectRecurringSubscriptions(List<Transaction> transactions) {
    final Map<String, List<Transaction>> merchantGroups = {};
    
    // Group transactions by merchant name
    for (final transaction in transactions) {
      final merchantName = _normalizeMerchantName(transaction.merchantName ?? 'Unknown');
      
      // Only include expense transactions
      final direction = transaction.direction.toLowerCase();
      bool isExpense = false;
      
      if (direction == 'debit' || direction == 'out') {
        isExpense = true;
      } else if (direction != 'credit' && direction != 'in' && transaction.amount < 0) {
        isExpense = true;
      }
      
      if (isExpense && merchantName.isNotEmpty) {
        merchantGroups.putIfAbsent(merchantName, () => []).add(transaction);
      }
    }
    
    final List<SubscriptionData> subscriptions = [];
    
    // Analyze each merchant group for recurring patterns
    for (final entry in merchantGroups.entries) {
      final merchantName = entry.key;
      final merchantTransactions = entry.value..sort((a, b) => 
        (a.bookingDate ?? a.createdAt).compareTo(b.bookingDate ?? b.createdAt));
      
      // Need at least 2 transactions to detect pattern
      if (merchantTransactions.length < 2) continue;
      
      // Check if amounts are similar (allow 5% variance for subscriptions with tax changes)
      final amounts = merchantTransactions.map((t) => t.amount.abs()).toList();
      final avgAmount = amounts.reduce((a, b) => a + b) / amounts.length;
      final isAmountConsistent = amounts.every((amount) => 
        (amount - avgAmount).abs() / avgAmount < 0.05);
      
      // Check date intervals to detect frequency
      final dates = merchantTransactions.map((t) => t.bookingDate ?? t.createdAt).toList();
      final intervals = <int>[];
      
      for (int i = 1; i < dates.length; i++) {
        intervals.add(dates[i].difference(dates[i - 1]).inDays);
      }
      
      if (intervals.isEmpty) continue;
      
      final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
      final isIntervalConsistent = intervals.every((interval) => 
        (interval - avgInterval).abs() <= 3); // Allow 3-day variance
      
      // Determine if this looks like a subscription
      if (isAmountConsistent && isIntervalConsistent && avgInterval >= 25 && avgInterval <= 35) {
        // Monthly subscription
        final nextBillingDate = dates.last.add(Duration(days: avgInterval.round()));
        
        subscriptions.add(SubscriptionData(
          name: _beautifySubscriptionName(merchantName),
          amount: avgAmount,
          frequency: SubscriptionFrequency.monthly,
          nextBillingDate: nextBillingDate,
          merchantName: merchantName,
          icon: _getSubscriptionIcon(merchantName),
          color: _getSubscriptionColor(merchantName),
          lastTransactions: merchantTransactions.take(3).toList(),
        ));
      } else if (isAmountConsistent && isIntervalConsistent && avgInterval >= 6 && avgInterval <= 8) {
        // Weekly subscription
        final nextBillingDate = dates.last.add(Duration(days: avgInterval.round()));
        
        subscriptions.add(SubscriptionData(
          name: _beautifySubscriptionName(merchantName),
          amount: avgAmount,
          frequency: SubscriptionFrequency.weekly,
          nextBillingDate: nextBillingDate,
          merchantName: merchantName,
          icon: _getSubscriptionIcon(merchantName),
          color: _getSubscriptionColor(merchantName),
          lastTransactions: merchantTransactions.take(3).toList(),
        ));
      } else if (isAmountConsistent && isIntervalConsistent && avgInterval >= 85 && avgInterval <= 95) {
        // Quarterly subscription
        final nextBillingDate = dates.last.add(Duration(days: avgInterval.round()));
        
        subscriptions.add(SubscriptionData(
          name: _beautifySubscriptionName(merchantName),
          amount: avgAmount,
          frequency: SubscriptionFrequency.quarterly,
          nextBillingDate: nextBillingDate,
          merchantName: merchantName,
          icon: _getSubscriptionIcon(merchantName),
          color: _getSubscriptionColor(merchantName),
          lastTransactions: merchantTransactions.take(3).toList(),
        ));
      } else if (isAmountConsistent && isIntervalConsistent && avgInterval >= 360 && avgInterval <= 370) {
        // Yearly subscription
        final nextBillingDate = dates.last.add(Duration(days: avgInterval.round()));
        
        subscriptions.add(SubscriptionData(
          name: _beautifySubscriptionName(merchantName),
          amount: avgAmount,
          frequency: SubscriptionFrequency.yearly,
          nextBillingDate: nextBillingDate,
          merchantName: merchantName,
          icon: _getSubscriptionIcon(merchantName),
          color: _getSubscriptionColor(merchantName),
          lastTransactions: merchantTransactions.take(3).toList(),
        ));
      }
    }
    
    // Sort by amount descending
    subscriptions.sort((a, b) => b.amount.compareTo(a.amount));
    
    return subscriptions;
  }
  
  /// Normalize merchant name for better grouping
  static String _normalizeMerchantName(String name) {
    return name
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
  }
  
  /// Beautify subscription name for display
  static String _beautifySubscriptionName(String merchantName) {
    final Map<String, String> knownServices = {
      'netflix': 'Netflix',
      'spotify': 'Spotify',
      'amazon': 'Amazon Prime',
      'apple': 'Apple Services',
      'google': 'Google Services',
      'microsoft': 'Microsoft 365',
      'adobe': 'Adobe Creative',
      'dropbox': 'Dropbox',
      'gym': 'Gym Membership',
      'fitness': 'Fitness Club',
      'internet': 'Internet Service',
      'phone': 'Mobile Plan',
      'electric': 'Electricity',
      'water': 'Water Service',
      'insurance': 'Insurance',
    };
    
    for (final entry in knownServices.entries) {
      if (merchantName.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Capitalize first letter of each word
    return merchantName
      .split(' ')
      .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
      .join(' ');
  }
  
  /// Get icon for subscription based on merchant name
  static String _getSubscriptionIcon(String merchantName) {
    if (merchantName.contains('netflix')) return '📺';
    if (merchantName.contains('spotify')) return '🎵';
    if (merchantName.contains('amazon')) return '📦';
    if (merchantName.contains('apple')) return '🍎';
    if (merchantName.contains('google')) return '🔍';
    if (merchantName.contains('microsoft')) return '💻';
    if (merchantName.contains('adobe')) return '🎨';
    if (merchantName.contains('dropbox')) return '☁️';
    if (merchantName.contains('gym') || merchantName.contains('fitness')) return '💪';
    if (merchantName.contains('internet')) return '🌐';
    if (merchantName.contains('phone')) return '📱';
    if (merchantName.contains('electric')) return '⚡';
    if (merchantName.contains('water')) return '💧';
    if (merchantName.contains('insurance')) return '🛡️';
    if (merchantName.contains('food') || merchantName.contains('restaurant')) return '🍽️';
    return '💳';
  }
  
  /// Get color for subscription based on merchant name
  static Color _getSubscriptionColor(String merchantName) {
    if (merchantName.contains('netflix')) return const Color(0xFFE50914);
    if (merchantName.contains('spotify')) return const Color(0xFF1DB954);
    if (merchantName.contains('amazon')) return const Color(0xFFFF9900);
    if (merchantName.contains('apple')) return const Color(0xFF007AFF);
    if (merchantName.contains('google')) return const Color(0xFF4285F4);
    if (merchantName.contains('microsoft')) return const Color(0xFF0078D4);
    if (merchantName.contains('adobe')) return const Color(0xFFFF0000);
    if (merchantName.contains('dropbox')) return const Color(0xFF0061FF);
    if (merchantName.contains('gym') || merchantName.contains('fitness')) return const Color(0xFF4CAF50);
    if (merchantName.contains('electric')) return const Color(0xFFFFC107);
    if (merchantName.contains('water')) return const Color(0xFF2196F3);
    if (merchantName.contains('insurance')) return const Color(0xFF9C27B0);
    return const Color(0xFF6C757D);
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

/// Subscription frequency enumeration
enum SubscriptionFrequency {
  weekly,
  monthly,
  quarterly,
  yearly;
  
  String get displayName {
    switch (this) {
      case SubscriptionFrequency.weekly:
        return 'Weekly';
      case SubscriptionFrequency.monthly:
        return 'Monthly';
      case SubscriptionFrequency.quarterly:
        return 'Every 3 months';
      case SubscriptionFrequency.yearly:
        return 'Yearly';
    }
  }
  
  double getMonthlyAmount(double amount) {
    switch (this) {
      case SubscriptionFrequency.weekly:
        return amount * 4.33; // Average weeks per month
      case SubscriptionFrequency.monthly:
        return amount;
      case SubscriptionFrequency.quarterly:
        return amount / 3;
      case SubscriptionFrequency.yearly:
        return amount / 12;
    }
  }
}

/// Subscription data model
class SubscriptionData {
  final String name;
  final double amount;
  final SubscriptionFrequency frequency;
  final DateTime nextBillingDate;
  final String merchantName;
  final String icon;
  final Color color;
  final List<Transaction> lastTransactions;
  
  const SubscriptionData({
    required this.name,
    required this.amount,
    required this.frequency,
    required this.nextBillingDate,
    required this.merchantName,
    required this.icon,
    required this.color,
    required this.lastTransactions,
  });
  
  /// Get the monthly equivalent amount for comparison
  double get monthlyAmount => frequency.getMonthlyAmount(amount);
  
  /// Get next billing date formatted
  String get nextBillingFormatted {
    final now = DateTime.now();
    final difference = nextBillingDate.difference(now).inDays;
    
    if (difference < 0) return 'Overdue';
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference <= 7) return 'In $difference days';
    if (difference <= 30) return 'In ${(difference / 7).floor()} weeks';
    return 'In ${(difference / 30).floor()} months';
  }
  
  /// Check if subscription is due soon (within 7 days)
  bool get isDueSoon {
    final now = DateTime.now();
    final difference = nextBillingDate.difference(now).inDays;
    return difference <= 7 && difference >= 0;
  }

  static List<SubscriptionData> fromTransactions(List<Transaction> transactions) {

    return InsightsService.detectRecurringSubscriptions(transactions);
  }

  static List<SubscriptionData> exampleSubscriptions = [
    SubscriptionData(
      name: 'Netflix',
      amount: 15.99,
      frequency: SubscriptionFrequency.monthly,
      nextBillingDate: DateTime.now().add(const Duration(days: 5)),
      merchantName: 'Netflix',
      icon: '📺',
      color: const Color(0xFFE50914),
      lastTransactions: [],
    ),
    SubscriptionData(
      name: 'Spotify',
      amount: 9.99,
      frequency: SubscriptionFrequency.monthly,
      nextBillingDate: DateTime.now().add(const Duration(days: 12)),
      merchantName: 'Spotify',
      icon: '🎵',
      color: const Color(0xFF1DB954),
      lastTransactions: [],
    ),
    SubscriptionData(
      name: 'Amazon Prime',
      amount: 119.00,
      frequency: SubscriptionFrequency.yearly,
      nextBillingDate: DateTime.now().add(const Duration(days: 200)),
      merchantName: 'Amazon',
      icon: '📦',
      color: const Color(0xFFFF9900),
      lastTransactions: [],
    ),
  ];
}

/// Subscription summary data
class SubscriptionSummary {
  final List<SubscriptionData> subscriptions;
  final double totalMonthlyAmount;
  final double totalYearlyAmount;
  final int activeCount;
  
  const SubscriptionSummary({
    required this.subscriptions,
    required this.totalMonthlyAmount,
    required this.totalYearlyAmount,
    required this.activeCount,
  });
  
  factory SubscriptionSummary.fromSubscriptions(List<SubscriptionData> subscriptions) {
    final totalMonthly = subscriptions.fold<double>(
      0.0,
      (sum, sub) => sum + sub.monthlyAmount,
    );
    
    return SubscriptionSummary(
      subscriptions: subscriptions,
      totalMonthlyAmount: totalMonthly,
      totalYearlyAmount: totalMonthly * 12,
      activeCount: subscriptions.length,
    );
  }
}