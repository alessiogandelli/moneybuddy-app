import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/services/mock_transaction_service.dart';
import 'add_transaction_event.dart';
import 'add_transaction_state.dart';

/// BLoC for managing transaction addition functionality
class AddTransactionBloc extends Bloc<AddTransactionEvent, AddTransactionState> {
  final TransactionRepository _transactionRepository;

  AddTransactionBloc({
    required TransactionRepository transactionRepository,
  }) : _transactionRepository = transactionRepository,
       super(AddTransactionInitial()) {
    
    // Register event handlers
    on<StartAddingTransaction>(_onStartAddingTransaction);
    on<UpdateTransactionForm>(_onUpdateTransactionForm);
    on<ValidateTransactionForm>(_onValidateTransactionForm);
    on<SubmitTransaction>(_onSubmitTransaction);
    on<AddTransactionFromVoice>(_onAddTransactionFromVoice);
    on<AddTransactionFromReceipt>(_onAddTransactionFromReceipt);
    on<ResetTransactionForm>(_onResetTransactionForm);
    on<LoadMerchantSuggestions>(_onLoadMerchantSuggestions);
    on<SelectMerchantSuggestion>(_onSelectMerchantSuggestion);
    on<SetTransactionInputMethod>(_onSetTransactionInputMethod);
  }

  /// Handle starting a new transaction
  Future<void> _onStartAddingTransaction(
    StartAddingTransaction event,
    Emitter<AddTransactionState> emit,
  ) async {
    emit(AddTransactionFormInProgress(
      formData: TransactionFormData(),
    ));
  }

  /// Handle form updates
  Future<void> _onUpdateTransactionForm(
    UpdateTransactionForm event,
    Emitter<AddTransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AddTransactionFormInProgress) return;

    final updatedFormData = currentState.formData.copyWith(
      merchantName: event.merchantName ?? currentState.formData.merchantName,
      amount: event.amount ?? currentState.formData.amount,
      currency: event.currency ?? currentState.formData.currency,
      direction: event.direction ?? currentState.formData.direction,
      category: event.category ?? currentState.formData.category,
      description: event.description ?? currentState.formData.description,
      date: event.date ?? currentState.formData.date,
      trxType: event.trxType ?? currentState.formData.trxType,
    );

    emit(currentState.copyWith(
      formData: updatedFormData,
      isValid: updatedFormData.isValid,
      validationErrors: updatedFormData.validationErrors,
    ));
  }

  /// Handle form validation
  Future<void> _onValidateTransactionForm(
    ValidateTransactionForm event,
    Emitter<AddTransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AddTransactionFormInProgress) return;

    emit(currentState.copyWith(
      isValid: currentState.formData.isValid,
      validationErrors: currentState.formData.validationErrors,
    ));
  }

  /// Handle transaction submission
  Future<void> _onSubmitTransaction(
    SubmitTransaction event,
    Emitter<AddTransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AddTransactionFormInProgress) return;

    if (!currentState.formData.isValid) {
      emit(AddTransactionError(
        message: 'Please fix the form errors before submitting',
        formData: currentState.formData,
      ));
      return;
    }

    try {
      emit(AddTransactionSubmitting(currentState.formData));

      final transaction = currentState.formData.toTransaction();
      final createdTransaction = await _transactionRepository.createTransaction(transaction);

      emit(AddTransactionSuccess(createdTransaction));
    } catch (e) {
      debugPrint('Error submitting transaction: $e');
      emit(AddTransactionError(
        message: _getErrorMessage(e),
        formData: currentState.formData,
      ));
    }
  }

  /// Handle voice input processing
  Future<void> _onAddTransactionFromVoice(
    AddTransactionFromVoice event,
    Emitter<AddTransactionState> emit,
  ) async {
    try {
      emit(AddTransactionProcessingVoice(event.audioPath));

      final transaction = await _transactionRepository.createTransactionFromVoice(
        event.audioPath,
        language: event.language,
      );

      emit(AddTransactionSuccess(transaction));
    } catch (e) {
      debugPrint('Error processing voice input: $e');
      emit(AddTransactionError(
        message: 'Failed to process voice input: ${_getErrorMessage(e)}',
      ));
    }
  }

  /// Handle receipt processing
  Future<void> _onAddTransactionFromReceipt(
    AddTransactionFromReceipt event,
    Emitter<AddTransactionState> emit,
  ) async {
    try {
      emit(AddTransactionProcessingReceipt(event.imagePath));

      final transaction = await _transactionRepository.createTransactionFromReceipt(
        event.imagePath,
        metadata: event.metadata,
      );

      emit(AddTransactionSuccess(transaction));
    } catch (e) {
      debugPrint('Error processing receipt: $e');
      emit(AddTransactionError(
        message: 'Failed to process receipt: ${_getErrorMessage(e)}',
      ));
    }
  }

  /// Handle form reset
  Future<void> _onResetTransactionForm(
    ResetTransactionForm event,
    Emitter<AddTransactionState> emit,
  ) async {
    emit(AddTransactionFormInProgress(
      formData: TransactionFormData(),
    ));
  }

  /// Handle merchant suggestions loading
  Future<void> _onLoadMerchantSuggestions(
    LoadMerchantSuggestions event,
    Emitter<AddTransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AddTransactionFormInProgress) return;

    if (event.query.isEmpty) {
      emit(currentState.copyWith(merchantSuggestions: []));
      return;
    }

    try {
      emit(AddTransactionLoadingSuggestions(event.query));

      // Get merchant suggestions from the mock service
      final allMerchants = MockTransactionService.getMerchantNames();
      final filteredMerchants = allMerchants
          .where((merchant) => merchant.toLowerCase().contains(event.query.toLowerCase()))
          .take(5)
          .toList();

      emit(currentState.copyWith(
        merchantSuggestions: filteredMerchants,
      ));
    } catch (e) {
      debugPrint('Error loading merchant suggestions: $e');
      emit(currentState.copyWith(merchantSuggestions: []));
    }
  }

  /// Handle merchant suggestion selection
  Future<void> _onSelectMerchantSuggestion(
    SelectMerchantSuggestion event,
    Emitter<AddTransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AddTransactionFormInProgress) return;

    final updatedFormData = currentState.formData.copyWith(
      merchantName: event.merchantName,
      category: event.category ?? currentState.formData.category,
    );

    emit(currentState.copyWith(
      formData: updatedFormData,
      merchantSuggestions: [],
      isValid: updatedFormData.isValid,
      validationErrors: updatedFormData.validationErrors,
    ));
  }

  /// Handle input method change
  Future<void> _onSetTransactionInputMethod(
    SetTransactionInputMethod event,
    Emitter<AddTransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AddTransactionFormInProgress) return;

    emit(currentState.copyWith(
      inputMethod: event.inputMethod,
    ));
  }

  /// Helper method to extract user-friendly error messages
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('timeout') || 
        error.toString().contains('connection')) {
      return 'Connection timeout. Please check your internet connection.';
    }
    
    if (error.toString().contains('permission')) {
      return 'Permission denied. Please check app permissions.';
    }
    
    if (error.toString().contains('network') || 
        error.toString().contains('socket')) {
      return 'Network error. Please try again later.';
    }
    
    // Default generic message
    return 'An unexpected error occurred. Please try again.';
  }

  /// Get current form data (useful for UI)
  TransactionFormData? get currentFormData {
    final currentState = state;
    if (currentState is AddTransactionFormInProgress) {
      return currentState.formData;
    }
    if (currentState is AddTransactionSubmitting) {
      return currentState.formData;
    }
    if (currentState is AddTransactionError) {
      return currentState.formData;
    }
    return null;
  }

  /// Check if form is currently valid
  bool get isFormValid {
    final currentState = state;
    if (currentState is AddTransactionFormInProgress) {
      return currentState.isValid;
    }
    return false;
  }

  /// Get current validation errors
  List<String> get validationErrors {
    final currentState = state;
    if (currentState is AddTransactionFormInProgress) {
      return currentState.validationErrors;
    }
    return [];
  }

  /// Check if currently processing
  bool get isProcessing {
    return state is AddTransactionSubmitting ||
           state is AddTransactionProcessingVoice ||
           state is AddTransactionProcessingReceipt ||
           state is AddTransactionLoadingSuggestions;
  }

  /// Quick method to update a single form field
  void updateField({
    String? merchantName,
    double? amount,
    String? currency,
    String? direction,
    String? category,
    String? description,
    DateTime? date,
    String? trxType,
  }) {
    add(UpdateTransactionForm(
      merchantName: merchantName,
      amount: amount,
      currency: currency,
      direction: direction,
      category: category,
      description: description,
      date: date,
      trxType: trxType,
    ));
  }

  /// Quick method to submit form
  void submit() {
    add(ValidateTransactionForm());
    add(SubmitTransaction());
  }

  /// Quick method to reset form
  void reset() {
    add(ResetTransactionForm());
  }
}