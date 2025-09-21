import 'package:equatable/equatable.dart';
import '../../../data/models/transaction.dart';
import 'add_transaction_event.dart';

/// States for add transaction BLoC
abstract class AddTransactionState extends Equatable {
  const AddTransactionState();
}

/// Initial state
class AddTransactionInitial extends AddTransactionState {
  @override
  List<Object> get props => [];
}

/// State when form is being filled
class AddTransactionFormInProgress extends AddTransactionState {
  final TransactionFormData formData;
  final List<String> validationErrors;
  final bool isValid;
  final List<String> merchantSuggestions;
  final TransactionInputMethod inputMethod;

  const AddTransactionFormInProgress({
    required this.formData,
    this.validationErrors = const [],
    this.isValid = false,
    this.merchantSuggestions = const [],
    this.inputMethod = TransactionInputMethod.manual,
  });

  @override
  List<Object> get props => [
    formData,
    validationErrors,
    isValid,
    merchantSuggestions,
    inputMethod,
  ];

  AddTransactionFormInProgress copyWith({
    TransactionFormData? formData,
    List<String>? validationErrors,
    bool? isValid,
    List<String>? merchantSuggestions,
    TransactionInputMethod? inputMethod,
  }) {
    return AddTransactionFormInProgress(
      formData: formData ?? this.formData,
      validationErrors: validationErrors ?? this.validationErrors,
      isValid: isValid ?? this.isValid,
      merchantSuggestions: merchantSuggestions ?? this.merchantSuggestions,
      inputMethod: inputMethod ?? this.inputMethod,
    );
  }
}

/// State when processing voice input
class AddTransactionProcessingVoice extends AddTransactionState {
  final String audioPath;

  const AddTransactionProcessingVoice(this.audioPath);

  @override
  List<Object> get props => [audioPath];
}

/// State when processing receipt image
class AddTransactionProcessingReceipt extends AddTransactionState {
  final String imagePath;

  const AddTransactionProcessingReceipt(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

/// State when submitting transaction
class AddTransactionSubmitting extends AddTransactionState {
  final TransactionFormData formData;

  const AddTransactionSubmitting(this.formData);

  @override
  List<Object> get props => [formData];
}

/// State when transaction successfully submitted
class AddTransactionSuccess extends AddTransactionState {
  final Transaction transaction;

  const AddTransactionSuccess(this.transaction);

  @override
  List<Object> get props => [transaction];
}

/// State when there's an error
class AddTransactionError extends AddTransactionState {
  final String message;
  final String? errorCode;
  final TransactionFormData? formData;

  const AddTransactionError({
    required this.message,
    this.errorCode,
    this.formData,
  });

  @override
  List<Object?> get props => [message, errorCode, formData];
}

/// State when loading merchant suggestions
class AddTransactionLoadingSuggestions extends AddTransactionState {
  final String query;

  const AddTransactionLoadingSuggestions(this.query);

  @override
  List<Object> get props => [query];
}

/// Data class for transaction form
class TransactionFormData extends Equatable {
  final String? merchantName;
  final double? amount;
  final String currency;
  final String direction;
  final String? category;
  final String? description;
  final DateTime date;
  final String trxType;
  final String? accountIban;
  final String? referenceNr;
  final Map<String, dynamic>? metadata;

  TransactionFormData({
    this.merchantName,
    this.amount,
    this.currency = 'CHF',
    this.direction = 'debit',
    this.category,
    this.description,
    DateTime? date,
    this.trxType = 'PAYMENT',
    this.accountIban,
    this.referenceNr,
    this.metadata,
  }) : date = date ?? DateTime.now();

  @override
  List<Object?> get props => [
    merchantName,
    amount,
    currency,
    direction,
    category,
    description,
    date,
    trxType,
    accountIban,
    referenceNr,
    metadata,
  ];

  TransactionFormData copyWith({
    String? merchantName,
    double? amount,
    String? currency,
    String? direction,
    String? category,
    String? description,
    DateTime? date,
    String? trxType,
    String? accountIban,
    String? referenceNr,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionFormData(
      merchantName: merchantName ?? this.merchantName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      direction: direction ?? this.direction,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      trxType: trxType ?? this.trxType,
      accountIban: accountIban ?? this.accountIban,
      referenceNr: referenceNr ?? this.referenceNr,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert form data to Transaction
  Transaction toTransaction() {
    final now = DateTime.now();
    return Transaction(
      trxId: 'TEMP-${now.millisecondsSinceEpoch}',
      direction: direction,
      amount: amount ?? 0.0,
      currency: currency,
      merchantName: merchantName,
      merchantFullText: description ?? merchantName,
      trxType: trxType,
      valueDate: date,
      bookingDate: date,
      accountIban: accountIban,
      referenceNr: referenceNr,
      rawPayload: metadata,
      createdAt: now,
      updatedAt: now,
      category: category ?? 'other'
    );
  }

  /// Check if form has minimum required data
  bool get hasRequiredData {
    return merchantName?.isNotEmpty == true && amount != null && amount! > 0;
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];

    if (merchantName?.isEmpty ?? true) {
      errors.add('Merchant name is required');
    }

    if (amount == null || amount! <= 0) {
      errors.add('Amount must be greater than 0');
    }

    if (currency.isEmpty) {
      errors.add('Currency is required');
    }

    if (direction.isEmpty) {
      errors.add('Transaction direction is required');
    }

    return errors;
  }

  /// Check if form is valid
  bool get isValid => validationErrors.isEmpty;
}

/// Helper class for merchant suggestions
class MerchantSuggestion extends Equatable {
  final String name;
  final String? category;
  final String? trxType;
  final double? averageAmount;

  const MerchantSuggestion({
    required this.name,
    this.category,
    this.trxType,
    this.averageAmount,
  });

  @override
  List<Object?> get props => [name, category, trxType, averageAmount];
}