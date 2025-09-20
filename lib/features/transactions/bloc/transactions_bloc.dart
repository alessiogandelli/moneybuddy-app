import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/transaction.dart';
import '../../../data/repositories/transaction_repository.dart';

/// Events for the transactions BLoC
abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object> get props => [];
}

class LoadTransactions extends TransactionsEvent {
  final bool forceRefresh;
  
  const LoadTransactions({this.forceRefresh = false});
  
  @override
  List<Object> get props => [forceRefresh];
}

class RefreshTransactions extends TransactionsEvent {
  const RefreshTransactions();
}

/// States for the transactions BLoC
abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;
  
  const TransactionsLoaded(this.transactions);
  
  @override
  List<Object> get props => [transactions];
}

class TransactionsError extends TransactionsState {
  final String message;
  
  const TransactionsError(this.message);
  
  @override
  List<Object> get props => [message];
}

/// BLoC for managing transactions
class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionRepository _transactionRepository;

  TransactionsBloc({
    required TransactionRepository transactionRepository,
  }) : _transactionRepository = transactionRepository,
       super(TransactionsInitial()) {
    
    on<LoadTransactions>(_onLoadTransactions);
    on<RefreshTransactions>(_onRefreshTransactions);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      emit(TransactionsLoading());
      
      final transactions = await _transactionRepository.getTransactions(
        forceRefresh: event.forceRefresh,
      );
      
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionsError('Failed to load transactions: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactions event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      final transactions = await _transactionRepository.getTransactions(
        forceRefresh: true,
      );
      
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionsError('Failed to refresh transactions: ${e.toString()}'));
    }
  }
}