import 'package:flutter/material.dart';
import '../services/insights_service.dart';
import '../models/transaction.dart';

/// Demo data service for testing subscription detection functionality
class SubscriptionDemoService {
  /// Generate sample recurring transactions for demonstration
  static List<Transaction> generateSampleRecurringTransactions() {
    final now = DateTime.now();
    final transactions = <Transaction>[];
    
    // Netflix subscription - monthly
    for (int i = 0; i < 6; i++) {
      transactions.add(Transaction.sample(
        trxId: 'NETFLIX-${now.subtract(Duration(days: 30 * i)).millisecondsSinceEpoch}',
        merchantName: 'Netflix',
        amount: -19.99,
        direction: 'debit',
        currency: 'CHF',
      ).copyWith(
        bookingDate: now.subtract(Duration(days: 30 * i)),
        valueDate: now.subtract(Duration(days: 30 * i)),
      ));
    }
    
    // Spotify subscription - monthly
    for (int i = 0; i < 5; i++) {
      transactions.add(Transaction.sample(
        trxId: 'SPOTIFY-${now.subtract(Duration(days: 31 * i + 5)).millisecondsSinceEpoch}',
        merchantName: 'Spotify Premium',
        amount: -12.99,
        direction: 'debit',
        currency: 'CHF',
      ).copyWith(
        bookingDate: now.subtract(Duration(days: 31 * i + 5)),
        valueDate: now.subtract(Duration(days: 31 * i + 5)),
      ));
    }
    
    // Amazon Prime - yearly
    transactions.add(Transaction.sample(
      trxId: 'AMAZON-${now.subtract(Duration(days: 30)).millisecondsSinceEpoch}',
      merchantName: 'Amazon Prime',
      amount: -99.00,
      direction: 'debit',
      currency: 'CHF',
    ).copyWith(
      bookingDate: now.subtract(Duration(days: 30)),
      valueDate: now.subtract(Duration(days: 30)),
    ));
    
    transactions.add(Transaction.sample(
      trxId: 'AMAZON-${now.subtract(Duration(days: 395)).millisecondsSinceEpoch}',
      merchantName: 'Amazon Prime',
      amount: -95.00, // Slight price change
      direction: 'debit',
      currency: 'CHF',
    ).copyWith(
      bookingDate: now.subtract(Duration(days: 395)),
      valueDate: now.subtract(Duration(days: 395)),
    ));
    
    // Gym membership - monthly
    for (int i = 0; i < 4; i++) {
      transactions.add(Transaction.sample(
        trxId: 'GYM-${now.subtract(Duration(days: 29 * i + 12)).millisecondsSinceEpoch}',
        merchantName: 'Fitness First Gym',
        amount: -65.00,
        direction: 'debit',
        currency: 'CHF',
      ).copyWith(
        bookingDate: now.subtract(Duration(days: 29 * i + 12)),
        valueDate: now.subtract(Duration(days: 29 * i + 12)),
      ));
    }
    
    // Adobe Creative Cloud - monthly
    for (int i = 0; i < 3; i++) {
      transactions.add(Transaction.sample(
        trxId: 'ADOBE-${now.subtract(Duration(days: 30 * i + 20)).millisecondsSinceEpoch}',
        merchantName: 'Adobe Creative Cloud',
        amount: -29.99,
        direction: 'debit',
        currency: 'CHF',
      ).copyWith(
        bookingDate: now.subtract(Duration(days: 30 * i + 20)),
        valueDate: now.subtract(Duration(days: 30 * i + 20)),
      ));
    }
    
    // Phone plan - monthly  
    for (int i = 0; i < 4; i++) {
      transactions.add(Transaction.sample(
        trxId: 'PHONE-${now.subtract(Duration(days: 30 * i + 3)).millisecondsSinceEpoch}',
        merchantName: 'Swisscom Mobile',
        amount: -45.00,
        direction: 'debit',
        currency: 'CHF',
      ).copyWith(
        bookingDate: now.subtract(Duration(days: 30 * i + 3)),
        valueDate: now.subtract(Duration(days: 30 * i + 3)),
      ));
    }
    
    // Some non-recurring transactions to test filtering
    transactions.add(Transaction.sample(
      trxId: 'GROCERY-${now.millisecondsSinceEpoch}',
      merchantName: 'Migros',
      amount: -85.50,
      direction: 'debit',
      currency: 'CHF',
    ));
    
    transactions.add(Transaction.sample(
      trxId: 'RESTAURANT-${now.subtract(Duration(days: 5)).millisecondsSinceEpoch}',
      merchantName: 'Restaurant Belle Vue',
      amount: -67.80,
      direction: 'debit',
      currency: 'CHF',
    ).copyWith(
      bookingDate: now.subtract(Duration(days: 5)),
    ));
    
    return transactions;
  }
  
  /// Test subscription detection with sample data
  static SubscriptionSummary testSubscriptionDetection() {
    final sampleTransactions = generateSampleRecurringTransactions();
    final detectedSubscriptions = InsightsService.detectRecurringSubscriptions(sampleTransactions);
    
    debugPrint('🧪 Testing subscription detection:');
    debugPrint('📊 Found ${detectedSubscriptions.length} subscriptions');
    
    for (final subscription in detectedSubscriptions) {
      debugPrint('  • ${subscription.name}: CHF ${subscription.amount.toStringAsFixed(2)} ${subscription.frequency.displayName.toLowerCase()}');
      debugPrint('    Monthly equivalent: CHF ${subscription.monthlyAmount.toStringAsFixed(2)}');
      debugPrint('    Next billing: ${subscription.nextBillingFormatted}');
    }
    
    final summary = SubscriptionSummary.fromSubscriptions(detectedSubscriptions);
    debugPrint('💰 Total monthly: CHF ${summary.totalMonthlyAmount.toStringAsFixed(2)}');
    debugPrint('💰 Total yearly: CHF ${summary.totalYearlyAmount.toStringAsFixed(2)}');
    
    return summary;
  }
}

/// Extension to add copyWith method to Transaction for demo purposes
extension TransactionDemo on Transaction {
  Transaction copyWith({
    int? id,
    String? trxId,
    String? accountIban,
    String? accountName,
    String? accountCurrency,
    String? customerName,
    String? product,
    String? trxType,
    String? bookingType,
    DateTime? valueDate,
    DateTime? bookingDate,
    String? direction,
    double? amount,
    String? currency,
    String? merchantName,
    String? merchantFullText,
    String? merchantPhone,
    String? merchantAddress,
    String? merchantIban,
    String? cardIdMasked,
    String? acquirerCountry,
    String? referenceNr,
    Map<String, dynamic>? rawPayload,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      trxId: trxId ?? this.trxId,
      accountIban: accountIban ?? this.accountIban,
      accountName: accountName ?? this.accountName,
      accountCurrency: accountCurrency ?? this.accountCurrency,
      customerName: customerName ?? this.customerName,
      product: product ?? this.product,
      trxType: trxType ?? this.trxType,
      bookingType: bookingType ?? this.bookingType,
      valueDate: valueDate ?? this.valueDate,
      bookingDate: bookingDate ?? this.bookingDate,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      merchantName: merchantName ?? this.merchantName,
      merchantFullText: merchantFullText ?? this.merchantFullText,
      merchantPhone: merchantPhone ?? this.merchantPhone,
      merchantAddress: merchantAddress ?? this.merchantAddress,
      merchantIban: merchantIban ?? this.merchantIban,
      cardIdMasked: cardIdMasked ?? this.cardIdMasked,
      acquirerCountry: acquirerCountry ?? this.acquirerCountry,
      referenceNr: referenceNr ?? this.referenceNr,
      rawPayload: rawPayload ?? this.rawPayload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? 'other',
    );
  }
}