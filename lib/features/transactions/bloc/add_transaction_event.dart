import 'package:equatable/equatable.dart';

/// Events for add transaction BLoC
abstract class AddTransactionEvent extends Equatable {
  const AddTransactionEvent();
}

/// Event to start adding a new transaction
class StartAddingTransaction extends AddTransactionEvent {
  @override
  List<Object> get props => [];
}

/// Event to update transaction form data
class UpdateTransactionForm extends AddTransactionEvent {
  final String? merchantName;
  final double? amount;
  final String? currency;
  final String? direction;
  final String? category;
  final String? description;
  final DateTime? date;
  final String? trxType;

  const UpdateTransactionForm({
    this.merchantName,
    this.amount,
    this.currency,
    this.direction,
    this.category,
    this.description,
    this.date,
    this.trxType,
  });

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
  ];
}

/// Event to validate the form
class ValidateTransactionForm extends AddTransactionEvent {
  @override
  List<Object> get props => [];
}

/// Event to submit the transaction
class SubmitTransaction extends AddTransactionEvent {
  @override
  List<Object> get props => [];
}

/// Event to add transaction from voice input
class AddTransactionFromVoice extends AddTransactionEvent {
  final String audioPath;
  final String? language;

  const AddTransactionFromVoice({
    required this.audioPath,
    this.language = 'en',
  });

  @override
  List<Object?> get props => [audioPath, language];
}

/// Event to add transaction from receipt
class AddTransactionFromReceipt extends AddTransactionEvent {
  final String imagePath;
  final Map<String, dynamic>? metadata;

  const AddTransactionFromReceipt({
    required this.imagePath,
    this.metadata,
  });

  @override
  List<Object?> get props => [imagePath, metadata];
}

/// Event to reset the form
class ResetTransactionForm extends AddTransactionEvent {
  @override
  List<Object> get props => [];
}

/// Event to load merchant suggestions
class LoadMerchantSuggestions extends AddTransactionEvent {
  final String query;

  const LoadMerchantSuggestions(this.query);

  @override
  List<Object> get props => [query];
}

/// Event to select a suggested merchant
class SelectMerchantSuggestion extends AddTransactionEvent {
  final String merchantName;
  final String? category;

  const SelectMerchantSuggestion({
    required this.merchantName,
    this.category,
  });

  @override
  List<Object?> get props => [merchantName, category];
}

/// Event to set transaction type from input method
class SetTransactionInputMethod extends AddTransactionEvent {
  final TransactionInputMethod inputMethod;

  const SetTransactionInputMethod(this.inputMethod);

  @override
  List<Object> get props => [inputMethod];
}

/// Enum for different ways to input transactions
enum TransactionInputMethod {
  manual,
  voice,
  camera,
  receipt,
}