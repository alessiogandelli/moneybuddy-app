import 'dart:math';
import '../models/transaction.dart';

/// Mock service for generating realistic transaction data for development and testing
class MockTransactionService {
  static final Random _random = Random();
  
  /// Sample Swiss merchants and categories
  static const List<Map<String, dynamic>> _swissMerchants = [
    {
      'name': 'Migros',
      'category': 'Groceries',
      'type': TransactionTypes.cardPayment,
      'minAmount': 15.0,
      'maxAmount': 120.0,
    },
    {
      'name': 'Coop',
      'category': 'Groceries',
      'type': TransactionTypes.cardPayment,
      'minAmount': 20.0,
      'maxAmount': 95.0,
    },
    {
      'name': 'Denner',
      'category': 'Groceries',
      'type': TransactionTypes.cardPayment,
      'minAmount': 12.0,
      'maxAmount': 80.0,
    },
    {
      'name': 'SBB CFF FFS',
      'category': 'Transportation',
      'type': TransactionTypes.cardPayment,
      'minAmount': 8.50,
      'maxAmount': 85.0,
    },
    {
      'name': 'Swisscom',
      'category': 'Utilities',
      'type': TransactionTypes.payment,
      'minAmount': 45.0,
      'maxAmount': 120.0,
    },
    {
      'name': 'UBS Bank',
      'category': 'Banking',
      'type': TransactionTypes.fee,
      'minAmount': 5.0,
      'maxAmount': 25.0,
    },
    {
      'name': 'Netflix',
      'category': 'Entertainment',
      'type': TransactionTypes.payment,
      'minAmount': 12.90,
      'maxAmount': 19.90,
    },
    {
      'name': 'Spotify',
      'category': 'Entertainment',
      'type': TransactionTypes.payment,
      'minAmount': 9.90,
      'maxAmount': 16.90,
    },
    {
      'name': 'McDonald\'s',
      'category': 'Dining',
      'type': TransactionTypes.cardPayment,
      'minAmount': 8.0,
      'maxAmount': 25.0,
    },
    {
      'name': 'Starbucks',
      'category': 'Dining',
      'type': TransactionTypes.cardPayment,
      'minAmount': 4.50,
      'maxAmount': 15.0,
    },
    {
      'name': 'Shell',
      'category': 'Fuel',
      'type': TransactionTypes.cardPayment,
      'minAmount': 35.0,
      'maxAmount': 95.0,
    },
    {
      'name': 'Esso',
      'category': 'Fuel',
      'type': TransactionTypes.cardPayment,
      'minAmount': 40.0,
      'maxAmount': 90.0,
    },
    {
      'name': 'H&M',
      'category': 'Shopping',
      'type': TransactionTypes.cardPayment,
      'minAmount': 15.0,
      'maxAmount': 120.0,
    },
    {
      'name': 'Zara',
      'category': 'Shopping',
      'type': TransactionTypes.cardPayment,
      'minAmount': 25.0,
      'maxAmount': 180.0,
    },
    {
      'name': 'MediaMarkt',
      'category': 'Electronics',
      'type': TransactionTypes.cardPayment,
      'minAmount': 50.0,
      'maxAmount': 800.0,
    },
    {
      'name': 'Galaxus',
      'category': 'Online Shopping',
      'type': TransactionTypes.payment,
      'minAmount': 20.0,
      'maxAmount': 350.0,
    },
    {
      'name': 'Amazon',
      'category': 'Online Shopping',
      'type': TransactionTypes.payment,
      'minAmount': 15.0,
      'maxAmount': 250.0,
    },
    {
      'name': 'Apotheke',
      'category': 'Healthcare',
      'type': TransactionTypes.cardPayment,
      'minAmount': 8.0,
      'maxAmount': 85.0,
    },
  ];

  /// Sample income sources
  static const List<Map<String, dynamic>> _incomeSources = [
    {
      'name': 'Salary - Tech Corp AG',
      'category': 'Salary',
      'type': TransactionTypes.transfer,
      'amount': 7500.0,
    },
    {
      'name': 'Freelance Payment',
      'category': 'Freelance',
      'type': TransactionTypes.transfer,
      'amount': 1200.0,
    },
    {
      'name': 'Interest Payment UBS',
      'category': 'Interest',
      'type': TransactionTypes.interest,
      'amount': 15.50,
    },
    {
      'name': 'Cashback Reward',
      'category': 'Rewards',
      'type': TransactionTypes.transfer,
      'amount': 25.75,
    },
    {
      'name': 'Refund - Online Store',
      'category': 'Refund',
      'type': TransactionTypes.transfer,
      'amount': 89.90,
    },
  ];

  /// Swiss locations for merchant addresses
  static const List<String> _swissLocations = [
    'Zurich, CH',
    'Geneva, CH',
    'Basel, CH',
    'Bern, CH',
    'Lausanne, CH',
    'Winterthur, CH',
    'Lucerne, CH',
    'St. Gallen, CH',
    'Lugano, CH',
    'Biel, CH',
  ];

  /// Generate a single mock transaction
  static Transaction generateMockTransaction({
    bool isIncome = false,
    DateTime? date,
    String? merchantName,
    double? amount,
  }) {
    final now = DateTime.now();
    final transactionDate = date ?? _randomDateInPast(90);
    
    Map<String, dynamic> sourceData;
    double transactionAmount;
    
    if (isIncome) {
      sourceData = _incomeSources[_random.nextInt(_incomeSources.length)];
      transactionAmount = amount ?? (sourceData['amount'] as double);
    } else {
      sourceData = _swissMerchants[_random.nextInt(_swissMerchants.length)];
      final minAmount = sourceData['minAmount'] as double;
      final maxAmount = sourceData['maxAmount'] as double;
      transactionAmount = amount ?? -(minAmount + _random.nextDouble() * (maxAmount - minAmount));
    }

    final trxId = 'TXN-${transactionDate.millisecondsSinceEpoch}-${_random.nextInt(9999)}';
    final merchantNameFinal = merchantName ?? sourceData['name'] as String;
    final location = _swissLocations[_random.nextInt(_swissLocations.length)];

    return Transaction(
      id: _random.nextInt(100000) + 1,
      trxId: trxId,
      accountIban: 'CH93 0076 2011 6238 5295 7',
      accountName: 'Personal Checking',
      accountCurrency: 'CHF',
      customerName: 'John Doe',
      product: 'Maestro Card',
      trxType: sourceData['type'] as String,
      bookingType: _randomBookingType(),
      valueDate: transactionDate,
      bookingDate: transactionDate.add(Duration(days: _random.nextInt(2))),
      direction: isIncome ? TransactionDirection.credit : TransactionDirection.debit,
      amount: transactionAmount,
      currency: 'CHF',
      merchantName: merchantNameFinal,
      merchantFullText: _generateMerchantFullText(merchantNameFinal, location),
      merchantPhone: _generatePhoneNumber(),
      merchantAddress: location,
      merchantIban: _generateRandomIban(),
      cardIdMasked: _generateMaskedCardId(),
      acquirerCountry: 'CH',
      referenceNr: 'REF-${_random.nextInt(99999999)}',
      rawPayload: _generateRawPayload(merchantNameFinal, transactionAmount),
      createdAt: now,
      updatedAt: now,
      category: sourceData['category'] as String,
    );
  }

  /// Generate a list of mock transactions
  static List<Transaction> generateMockTransactions({
    int count = 50,
    int daysBack = 90,
    double incomeRatio = 0.15, // 15% income transactions
  }) {
    final transactions = <Transaction>[];
    final incomeCount = (count * incomeRatio).round();
    
    // Generate income transactions
    for (int i = 0; i < incomeCount; i++) {
      transactions.add(generateMockTransaction(
        isIncome: true,
        date: _randomDateInPast(daysBack),
      ));
    }
    
    // Generate expense transactions
    for (int i = 0; i < (count - incomeCount); i++) {
      transactions.add(generateMockTransaction(
        isIncome: false,
        date: _randomDateInPast(daysBack),
      ));
    }
    
    // Sort by date (newest first)
    transactions.sort((a, b) => (b.displayDate ?? b.createdAt).compareTo(a.displayDate ?? a.createdAt));
    
    return transactions;
  }

  /// Generate recent transactions for real-time updates
  static List<Transaction> generateRecentTransactions({int count = 5}) {
    final transactions = <Transaction>[];
    
    for (int i = 0; i < count; i++) {
      final hoursBack = _random.nextInt(48); // Last 48 hours
      final date = DateTime.now().subtract(Duration(hours: hoursBack));
      
      transactions.add(generateMockTransaction(
        isIncome: _random.nextDouble() < 0.2, // 20% income
        date: date,
      ));
    }
    
    return transactions;
  }

  /// Generate transactions for specific categories (useful for testing)
  static List<Transaction> generateCategoryTransactions(String category, {int count = 10}) {
    final categoryMerchants = _swissMerchants
        .where((m) => m['category'] == category)
        .toList();
    
    if (categoryMerchants.isEmpty) {
      return generateMockTransactions(count: count);
    }
    
    final transactions = <Transaction>[];
    
    for (int i = 0; i < count; i++) {
      final merchant = categoryMerchants[_random.nextInt(categoryMerchants.length)];
      final minAmount = merchant['minAmount'] as double;
      final maxAmount = merchant['maxAmount'] as double;
      final amount = -(minAmount + _random.nextDouble() * (maxAmount - minAmount));
      
      transactions.add(generateMockTransaction(
        isIncome: false,
        merchantName: merchant['name'] as String,
        amount: amount,
        date: _randomDateInPast(30),
      ));
    }
    
    return transactions;
  }

  /// Generate a transaction for voice/camera testing
  static Transaction generateTestTransaction({
    required String description,
    required double amount,
    String? category,
  }) {
    final now = DateTime.now();
    
    // Try to match description to known merchants
    final matchingMerchant = _swissMerchants.firstWhere(
      (m) => description.toLowerCase().contains((m['name'] as String).toLowerCase()),
      orElse: () => {
        'name': description,
        'category': category ?? 'Other',
        'type': TransactionTypes.payment,
      },
    );
    
    return Transaction(
      id: _random.nextInt(100000) + 1,
      trxId: 'TEST-${now.millisecondsSinceEpoch}',
      accountIban: 'CH93 0076 2011 6238 5295 7',
      accountName: 'Personal Checking',
      accountCurrency: 'CHF',
      customerName: 'John Doe',
      product: 'Voice/Camera Input',
      trxType: matchingMerchant['type'] as String? ?? TransactionTypes.payment,
      bookingType: BookingTypes.standard,
      valueDate: now,
      bookingDate: now,
      direction: amount < 0 ? TransactionDirection.debit : TransactionDirection.credit,
      amount: amount,
      currency: 'CHF',
      merchantName: matchingMerchant['name'] as String,
      merchantFullText: description,
      merchantPhone: _generatePhoneNumber(),
      merchantAddress: _swissLocations[_random.nextInt(_swissLocations.length)],
      cardIdMasked: _generateMaskedCardId(),
      acquirerCountry: 'CH',
      referenceNr: 'VOICE-${_random.nextInt(99999)}',
      rawPayload: {
        'input_method': 'voice_or_camera',
        'original_description': description,
        'processed_at': now.toIso8601String(),
      },
      createdAt: now,
      updatedAt: now,
      category: 'other'
    );
  }

  // Helper methods

  static DateTime _randomDateInPast(int maxDaysBack) {
    final daysBack = _random.nextInt(maxDaysBack);
    final hoursBack = _random.nextInt(24);
    final minutesBack = _random.nextInt(60);
    
    return DateTime.now().subtract(Duration(
      days: daysBack,
      hours: hoursBack,
      minutes: minutesBack,
    ));
  }

  static String _randomBookingType() {
    final types = [
      BookingTypes.standard,
      BookingTypes.pending,
    ];
    return types[_random.nextInt(types.length)];
  }

  static String _generateMerchantFullText(String merchantName, String location) {
    final templates = [
      '$merchantName $location',
      '$merchantName - $location',
      'PURCHASE $merchantName $location',
      'CARD PAYMENT $merchantName $location',
      '$merchantName RETAIL $location',
    ];
    
    return templates[_random.nextInt(templates.length)];
  }

  static String _generatePhoneNumber() {
    final prefixes = ['+41 44', '+41 21', '+41 31', '+41 61'];
    final prefix = prefixes[_random.nextInt(prefixes.length)];
    final number = _random.nextInt(8999999) + 1000000;
    return '$prefix $number';
  }

  static String _generateRandomIban() {
    final banks = ['0076', '0234', '0458', '0851'];
    final bank = banks[_random.nextInt(banks.length)];
    final account = _random.nextInt(99999999) + 10000000;
    final checksum = _random.nextInt(99) + 10;
    return 'CH$checksum $bank 2011 $account';
  }

  static String _generateMaskedCardId() {
    final lastFour = _random.nextInt(9999).toString().padLeft(4, '0');
    return '****-****-****-$lastFour';
  }

  static Map<String, dynamic> _generateRawPayload(String merchantName, double amount) {
    return {
      'original_merchant': merchantName,
      'original_amount': amount.abs(),
      'processing_date': DateTime.now().toIso8601String(),
      'batch_id': 'BATCH-${_random.nextInt(99999)}',
      'authorization_code': 'AUTH-${_random.nextInt(999999)}',
      'terminal_id': 'TERM-${_random.nextInt(9999)}',
    };
  }

  /// Mock API simulation - simulates network delay and occasional errors
  static Future<List<Transaction>> simulateApiCall<T>({
    required List<Transaction> Function() dataGenerator,
    double errorRate = 0.05, // 5% error rate
    int minDelayMs = 300,
    int maxDelayMs = 1500,
  }) async {
    // Simulate network delay
    final delayMs = minDelayMs + _random.nextInt(maxDelayMs - minDelayMs);
    await Future.delayed(Duration(milliseconds: delayMs));
    
    // Simulate occasional errors
    if (_random.nextDouble() < errorRate) {
      throw Exception('Mock API error: Network timeout');
    }
    
    return dataGenerator();
  }

  /// Get available categories for filtering
  static List<String> getAvailableCategories() {
    final categories = _swissMerchants
        .map((m) => m['category'] as String)
        .toSet()
        .toList();
    
    categories.sort();
    return categories;
  }

  /// Get sample merchant names for autocomplete
  static List<String> getMerchantNames() {
    return _swissMerchants
        .map((m) => m['name'] as String)
        .toList();
  }
}