import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/transaction_api_service.dart';
import '../services/mock_transaction_service.dart';
import '../local/hive_service.dart';

/// Repository for transaction data management combining API and local storage
class TransactionRepository {
  final TransactionApiService _apiService;
  final bool _useMockData;
  
  // Cache control
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const Duration _cacheValidDuration = Duration(minutes: 15);
  
  // Stream controllers for real-time updates
  final StreamController<List<Transaction>> _transactionsStreamController = 
      StreamController<List<Transaction>>.broadcast();
  final StreamController<Transaction> _transactionAddedController = 
      StreamController<Transaction>.broadcast();

  TransactionRepository({
    required TransactionApiService apiService,
    bool useMockData = false, // Always use real API by default
  }) : _apiService = apiService,
       _useMockData = useMockData;

  /// Stream of transaction updates
  Stream<List<Transaction>> get transactionsStream => _transactionsStreamController.stream;
  
  /// Stream of newly added transactions
  Stream<Transaction> get transactionAddedStream => _transactionAddedController.stream;

  /// Dispose resources
  void dispose() {
    _transactionsStreamController.close();
    _transactionAddedController.close();
  }

  /// Get all transactions with smart caching
  Future<List<Transaction>> getTransactions({
    bool forceRefresh = false,
    int? limit,
    int? offset,
    DateTime? fromDate,
    DateTime? toDate,
    String? accountIban,
  }) async {
    try {
      // Check cache first if not forcing refresh
      if (!forceRefresh && await _isCacheValid()) {
        final cachedTransactions = await _getCachedTransactions();
        if (cachedTransactions.isNotEmpty) {
          _transactionsStreamController.add(cachedTransactions);
          return cachedTransactions;
        }
      }

      // Fetch from API or generate mock data
      final List<Transaction> transactions;
      if (_useMockData) {
        transactions = await _getMockTransactions(
          limit: limit ?? 50,
          fromDate: fromDate,
          toDate: toDate,
        );
      } else {
        transactions = await _apiService.getTransactions(
          limit: limit,
          offset: offset,
          fromDate: fromDate,
          toDate: toDate,
          accountIban: accountIban,
        );
      }

      // Cache the results
      await _cacheTransactions(transactions);
      await _updateLastSyncTime();

      // Notify listeners
      _transactionsStreamController.add(transactions);
      
      return transactions;
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      
      // Fallback to cached data if API fails
      final cachedTransactions = await _getCachedTransactions();
      if (cachedTransactions.isNotEmpty) {
        _transactionsStreamController.add(cachedTransactions);
        return cachedTransactions;
      }
      
      rethrow;
    }
  }

  /// Get a specific transaction
  Future<Transaction?> getTransaction(String trxId) async {
    try {
      // Check cache first
      final cachedTransaction = await _getCachedTransaction(trxId);
      if (cachedTransaction != null) {
        return cachedTransaction;
      }

      // Fetch from API or mock
      final Transaction transaction;
      if (_useMockData) {
        // Generate a specific mock transaction
        transaction = MockTransactionService.generateMockTransaction();
      } else {
        transaction = await _apiService.getTransaction(trxId);
      }

      // Cache the transaction
      await _cacheTransaction(transaction);
      
      return transaction;
    } catch (e) {
      debugPrint('Error fetching transaction $trxId: $e');
      return null;
    }
  }

  /// Create a new transaction
  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final Transaction createdTransaction;
      
      if (_useMockData) {
        // Simulate creation with mock data
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        createdTransaction = transaction.copyWith(
          id: DateTime.now().millisecondsSinceEpoch,
          trxId: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        createdTransaction = await _apiService.createTransaction(transaction);
      }

      // Add to cache
      await _addTransactionToCache(createdTransaction);
      
      // Notify listeners
      _transactionAddedController.add(createdTransaction);
      
      // Refresh the main list
      final updatedTransactions = await _getCachedTransactions();
      _transactionsStreamController.add(updatedTransactions);
      
      return createdTransaction;
    } catch (e) {
      debugPrint('Error creating transaction: $e');
      rethrow;
    }
  }

  /// Update an existing transaction
  Future<Transaction> updateTransaction(String trxId, Transaction transaction) async {
    try {
      final Transaction updatedTransaction;
      
      if (_useMockData) {
        // Simulate update
        await Future.delayed(const Duration(milliseconds: 300));
        updatedTransaction = transaction.copyWith(
          updatedAt: DateTime.now(),
        );
      } else {
        updatedTransaction = await _apiService.updateTransaction(trxId, transaction);
      }

      // Update cache
      await _updateTransactionInCache(updatedTransaction);
      
      // Refresh the main list
      final updatedTransactions = await _getCachedTransactions();
      _transactionsStreamController.add(updatedTransactions);
      
      return updatedTransaction;
    } catch (e) {
      debugPrint('Error updating transaction $trxId: $e');
      rethrow;
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String trxId) async {
    try {
      if (!_useMockData) {
        await _apiService.deleteTransaction(trxId);
      } else {
        // Simulate deletion delay
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Remove from cache
      await _removeTransactionFromCache(trxId);
      
      // Refresh the main list
      final updatedTransactions = await _getCachedTransactions();
      _transactionsStreamController.add(updatedTransactions);
      
    } catch (e) {
      debugPrint('Error deleting transaction $trxId: $e');
      rethrow;
    }
  }

  /// Search transactions
  Future<List<Transaction>> searchTransactions(String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      if (_useMockData) {
        // Filter cached transactions for mock search
        final allTransactions = await _getCachedTransactions();
        final filteredTransactions = allTransactions.where((transaction) {
          final searchText = query.toLowerCase();
          return transaction.merchantName?.toLowerCase().contains(searchText) == true ||
                 transaction.merchantFullText?.toLowerCase().contains(searchText) == true ||
                 transaction.displayDescription.toLowerCase().contains(searchText) ||
                 transaction.amount.toString().contains(searchText);
        }).toList();
        
        return limit != null && limit < filteredTransactions.length
            ? filteredTransactions.take(limit).toList()
            : filteredTransactions;
      } else {
        return await _apiService.searchTransactions(query, limit: limit, offset: offset);
      }
    } catch (e) {
      debugPrint('Error searching transactions: $e');
      return [];
    }
  }

  /// Get transaction summary/statistics
  Future<TransactionSummary> getTransactionSummary({
    DateTime? fromDate,
    DateTime? toDate,
    String? accountIban,
  }) async {
    try {
      if (_useMockData) {
        // Generate mock summary from cached transactions
        final transactions = await _getCachedTransactions();
        return _calculateSummaryFromTransactions(transactions, fromDate, toDate);
      } else {
        return await _apiService.getTransactionSummary(
          fromDate: fromDate,
          toDate: toDate,
          accountIban: accountIban,
        );
      }
    } catch (e) {
      debugPrint('Error fetching transaction summary: $e');
      // Fallback to calculating from cached data
      final transactions = await _getCachedTransactions();
      return _calculateSummaryFromTransactions(transactions, fromDate, toDate);
    }
  }

  /// Create transaction from receipt image
  Future<Transaction> createTransactionFromReceipt(String imagePath, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (_useMockData) {
        // Generate mock transaction from receipt
        await Future.delayed(const Duration(seconds: 2)); // Simulate processing time
        final transaction = MockTransactionService.generateTestTransaction(
          description: 'Receipt Upload - ${DateTime.now().day}/${DateTime.now().month}',
          amount: -25.90, // Mock amount
          category: 'Dining',
        );
        
        return await createTransaction(transaction);
      } else {
        return await _apiService.uploadReceipt(imagePath, metadata: metadata);
      }
    } catch (e) {
      debugPrint('Error processing receipt: $e');
      rethrow;
    }
  }

  /// Create transaction from voice input
  Future<Transaction> createTransactionFromVoice(String audioPath, {
    String? language = 'en',
    Map<String, dynamic>? context,
  }) async {
    try {
      if (_useMockData) {
        // Generate mock transaction from voice
        await Future.delayed(const Duration(seconds: 1)); // Simulate processing
        final transaction = MockTransactionService.generateTestTransaction(
          description: 'Voice Input - Coffee Shop',
          amount: -8.50, // Mock amount
          category: 'Dining',
        );
        
        return await createTransaction(transaction);
      } else {
        return await _apiService.processVoiceInput(audioPath, language: language, context: context);
      }
    } catch (e) {
      debugPrint('Error processing voice input: $e');
      rethrow;
    }
  }

  /// Sync transactions with remote server
  Future<void> syncTransactions() async {
    try {
      await getTransactions(forceRefresh: true);
      debugPrint('Transactions synced successfully');
    } catch (e) {
      debugPrint('Error syncing transactions: $e');
      rethrow;
    }
  }

  /// Clear local cache
  Future<void> clearCache() async {
    await HiveService.clearCache();
  }

  // Private helper methods

  Future<List<Transaction>> _getMockTransactions({
    int limit = 50,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await MockTransactionService.simulateApiCall(
      dataGenerator: () => MockTransactionService.generateMockTransactions(
        count: limit,
        daysBack: fromDate != null ? DateTime.now().difference(fromDate).inDays : 90,
      ),
    );
  }

  Future<bool> _isCacheValid() async {
    try {
      final lastSyncTimestamp = HiveService.getCachedData<int>(_lastSyncKey);
      if (lastSyncTimestamp == null) return false;
      
      final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);
      final now = DateTime.now();
      
      return now.difference(lastSyncTime) < _cacheValidDuration;
    } catch (e) {
      debugPrint('Error checking cache validity: $e');
      return false;
    }
  }

  Future<List<Transaction>> _getCachedTransactions() async {
    try {
      // Use the robust HiveService method that handles broken entries
      return HiveService.getCachedTransactions();
    } catch (e) {
      debugPrint('Error getting cached transactions: $e');
      return [];
    }
  }

  Future<Transaction?> _getCachedTransaction(String trxId) async {
    final transactions = await _getCachedTransactions();
    try {
      return transactions.firstWhere((t) => t.trxId == trxId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheTransactions(List<Transaction> transactions) async {
    try {
      // Use the dedicated HiveService method for transactions
      await HiveService.saveTransactions(transactions);
    } catch (e) {
      debugPrint('Error caching transactions: $e');
    }
  }

  Future<void> _cacheTransaction(Transaction transaction) async {
    try {
      final transactions = await _getCachedTransactions();
      
      // Remove existing transaction with same ID if present
      transactions.removeWhere((t) => t.trxId == transaction.trxId);
      
      // Add new transaction at the beginning
      transactions.insert(0, transaction);
      
      await _cacheTransactions(transactions);
    } catch (e) {
      debugPrint('Error caching single transaction: $e');
    }
  }

  Future<void> _addTransactionToCache(Transaction transaction) async {
    await _cacheTransaction(transaction);
  }

  Future<void> _updateTransactionInCache(Transaction transaction) async {
    try {
      final transactions = await _getCachedTransactions();
      
      // Find and update the transaction
      final index = transactions.indexWhere((t) => t.trxId == transaction.trxId);
      if (index != -1) {
        transactions[index] = transaction;
        await _cacheTransactions(transactions);
      }
    } catch (e) {
      debugPrint('Error updating transaction in cache: $e');
    }
  }

  Future<void> _removeTransactionFromCache(String trxId) async {
    try {
      final transactions = await _getCachedTransactions();
      transactions.removeWhere((t) => t.trxId == trxId);
      await _cacheTransactions(transactions);
    } catch (e) {
      debugPrint('Error removing transaction from cache: $e');
    }
  }

  Future<void> _updateLastSyncTime() async {
    try {
      await HiveService.cacheData(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error updating last sync time: $e');
    }
  }

  TransactionSummary _calculateSummaryFromTransactions(
    List<Transaction> transactions,
    DateTime? fromDate,
    DateTime? toDate,
  ) {
    // Filter transactions by date if specified
    var filteredTransactions = transactions;
    if (fromDate != null || toDate != null) {
      filteredTransactions = transactions.where((t) {
        final transactionDate = t.displayDate ?? t.createdAt;
        if (fromDate != null && transactionDate.isBefore(fromDate)) return false;
        if (toDate != null && transactionDate.isAfter(toDate)) return false;
        return true;
      }).toList();
    }

    double totalIncome = 0;
    double totalExpenses = 0;
    final Map<String, double> categoryBreakdown = {};
    final Map<String, int> transactionsByType = {};

    for (final transaction in filteredTransactions) {
      if (transaction.isIncome) {
        totalIncome += transaction.absoluteAmount;
      } else {
        totalExpenses += transaction.absoluteAmount;
      }

      // Category breakdown (use merchant name as category for now)
      final category = transaction.merchantName ?? 'Other';
      categoryBreakdown[category] = (categoryBreakdown[category] ?? 0) + transaction.absoluteAmount;

      // Transaction type breakdown
      final type = transaction.trxType ?? 'OTHER';
      transactionsByType[type] = (transactionsByType[type] ?? 0) + 1;
    }

    return TransactionSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      balance: totalIncome - totalExpenses,
      transactionCount: filteredTransactions.length,
      periodStart: fromDate,
      periodEnd: toDate,
      categoryBreakdown: categoryBreakdown,
      transactionsByType: transactionsByType,
    );
  }
}