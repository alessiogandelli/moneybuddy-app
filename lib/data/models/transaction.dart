// import 'package:json_annotation/json_annotation.dart';
// import 'package:hive/hive.dart';

// TODO: Uncomment when dependencies are installed
// part 'transaction.g.dart';

// @JsonSerializable()
// @HiveType(typeId: 2)
/// Transaction model representing financial transactions with comprehensive banking data
class Transaction {
  // @HiveField(0) - Internal primary key
  final int? id;
  
  // @HiveField(1) - External unique transaction ID from feed
  final String trxId;
  
  // @HiveField(2) - Account information
  final String? accountIban;
  final String? accountName;
  final String? accountCurrency;
  
  // @HiveField(3) - Customer information  
  final String? customerName;
  final String? product;
  
  // @HiveField(4) - Transaction classification
  final String? trxType;
  final String? bookingType;
  
  // @HiveField(5) - Dates
  final DateTime? valueDate;
  final DateTime? bookingDate;
  
  // @HiveField(6) - Financial details
  final String direction; // debit/credit or IN/OUT
  final double amount;
  final String currency;
  
  // @HiveField(7) - Merchant information
  final String? merchantName;
  final String? merchantFullText;
  final String? merchantPhone;
  final String? merchantAddress;
  final String? merchantIban;
  
  // @HiveField(8) - Card and payment details
  final String? cardIdMasked;
  final String? acquirerCountry;
  final String? referenceNr;
  
  // @HiveField(9) - Audit and metadata
  final Map<String, dynamic>? rawPayload;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    this.id,
    required this.trxId,
    this.accountIban,
    this.accountName,
    this.accountCurrency,
    this.customerName,
    this.product,
    this.trxType,
    this.bookingType,
    this.valueDate,
    this.bookingDate,
    required this.direction,
    required this.amount,
    required this.currency,
    this.merchantName,
    this.merchantFullText,
    this.merchantPhone,
    this.merchantAddress,
    this.merchantIban,
    this.cardIdMasked,
    this.acquirerCountry,
    this.referenceNr,
    this.rawPayload,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int?,
      trxId: json['trx_id'] as String,
      accountIban: json['account_iban'] as String?,
      accountName: json['account_name'] as String?,
      accountCurrency: json['account_currency'] as String?,
      customerName: json['customer_name'] as String?,
      product: json['product'] as String?,
      trxType: json['trx_type'] as String?,
      bookingType: json['booking_type'] as String?,
      valueDate: json['value_date'] != null 
          ? DateTime.parse(json['value_date'] as String)
          : null,
      bookingDate: json['booking_date'] != null 
          ? DateTime.parse(json['booking_date'] as String)
          : null,
      direction: json['direction'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      merchantName: json['merchant_name'] as String?,
      merchantFullText: json['merchant_full_text'] as String?,
      merchantPhone: json['merchant_phone'] as String?,
      merchantAddress: json['merchant_address'] as String?,
      merchantIban: json['merchant_iban'] as String?,
      cardIdMasked: json['card_id_masked'] as String?,
      acquirerCountry: json['acquirer_country'] as String?,
      referenceNr: json['reference_nr'] as String?,
      rawPayload: json['raw_payload'] != null 
          ? Map<String, dynamic>.from(json['raw_payload'] as Map)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Create a sample transaction for testing/demo purposes
  factory Transaction.sample({
    String? trxId,
    String? merchantName,
    double? amount,
    String? direction,
    String? currency,
  }) {
    final now = DateTime.now();
    return Transaction(
      trxId: trxId ?? 'TXN-${now.millisecondsSinceEpoch}',
      direction: direction ?? TransactionDirection.debit,
      amount: amount ?? -25.50,
      currency: currency ?? 'CHF',
      merchantName: merchantName ?? 'Sample Merchant',
      accountCurrency: currency ?? 'CHF',
      bookingDate: now,
      valueDate: now,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  /// Convert transaction to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trx_id': trxId,
      'account_iban': accountIban,
      'account_name': accountName,
      'account_currency': accountCurrency,
      'customer_name': customerName,
      'product': product,
      'trx_type': trxType,
      'booking_type': bookingType,
      'value_date': valueDate?.toIso8601String(),
      'booking_date': bookingDate?.toIso8601String(),
      'direction': direction,
      'amount': amount,
      'currency': currency,
      'merchant_name': merchantName,
      'merchant_full_text': merchantFullText,
      'merchant_phone': merchantPhone,
      'merchant_address': merchantAddress,
      'merchant_iban': merchantIban,
      'card_id_masked': cardIdMasked,
      'acquirer_country': acquirerCountry,
      'reference_nr': referenceNr,
      'raw_payload': rawPayload,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy transaction with updated fields
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
    );
  }

  /// Check if transaction is a debit (outgoing/expense)
  bool get isDebit => direction.toLowerCase() == 'debit' || 
                      direction.toLowerCase() == 'out';

  /// Check if transaction is a credit (incoming/income)
  bool get isCredit => direction.toLowerCase() == 'credit' || 
                       direction.toLowerCase() == 'in';

  /// Check if transaction is an expense (negative amount or debit)
  bool get isExpense => amount < 0 || isDebit;

  /// Check if transaction is income (positive amount and credit)
  bool get isIncome => amount > 0 && isCredit;

  /// Get absolute amount for display
  double get absoluteAmount => amount.abs();

  /// Get formatted amount string with currency
  String get formattedAmount {
    final absAmount = absoluteAmount;
    return '$currency ${absAmount.toStringAsFixed(2)}';
  }

  /// Get a display description from available fields
  String get displayDescription {
    if (merchantName?.isNotEmpty == true) return merchantName!;
    if (merchantFullText?.isNotEmpty == true) return merchantFullText!;
    if (product?.isNotEmpty == true) return product!;
    return 'Transaction ${trxId}';
  }

  /// Get the relevant date for display (value date preferred, then booking date)
  DateTime? get displayDate => valueDate ?? bookingDate;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.trxId == trxId &&
        other.amount == amount &&
        other.direction == direction &&
        other.currency == currency;
  }

  @override
  int get hashCode => trxId.hashCode ^ amount.hashCode ^ direction.hashCode ^ currency.hashCode;
}

/// Common transaction directions
class TransactionDirection {
  static const String debit = 'debit';
  static const String credit = 'credit';
  static const String out = 'OUT';
  static const String incoming = 'IN';
  
  /// List of all valid directions
  static const List<String> all = [debit, credit, out, incoming];
  
  /// Check if direction is valid
  static bool isValid(String direction) => all.contains(direction);
}

/// Common transaction types from banking feeds
class TransactionTypes {
  static const String payment = 'PAYMENT';
  static const String transfer = 'TRANSFER';
  static const String cardPayment = 'CARD_PAYMENT';
  static const String withdrawal = 'WITHDRAWAL';
  static const String deposit = 'DEPOSIT';
  static const String fee = 'FEE';
  static const String interest = 'INTEREST';
}

/// Common booking types
class BookingTypes {
  static const String standard = 'STANDARD';
  static const String pending = 'PENDING';
  static const String reversed = 'REVERSED';
  static const String cancelled = 'CANCELLED';
}