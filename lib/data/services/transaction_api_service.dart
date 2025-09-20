import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/transaction.dart';

/// API service for transaction-related operations
class TransactionApiService {
  final Dio _dio;
  final String baseUrl;

  TransactionApiService({
    Dio? dio,
    this.baseUrl = 'http://localhost:420', // Your local API endpoint
  }) : _dio = dio ?? _createDefaultDio();

  static Dio _createDefaultDio() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add minimal logging for debugging (no response body to avoid flooding console)
    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      request: true,
      requestHeader: false,
      responseHeader: false,
      error: true,
      logPrint: (obj) => print('🌐 API: $obj'),
    ));
    
    return dio;
  }

  /// Set authentication token for API requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Get all transactions for the authenticated user
  Future<List<Transaction>> getTransactions({
    int? limit,
    int? offset,
    DateTime? fromDate,
    DateTime? toDate,
    String? accountIban,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String().split('T')[0];
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String().split('T')[0];
      if (accountIban != null) queryParams['account_iban'] = accountIban;

      final response = await _dio.get(
        '$baseUrl/transaction',
        queryParameters: queryParams,
        options: Options(
          responseType: ResponseType.plain, // Get as plain text first
        ),
      );

      if (response.statusCode == 200) {
        // Clean the response data by replacing NaN with null
        String responseData = response.data as String;
        
        // Replace invalid JSON values
        responseData = responseData
            .replaceAll(': NaN,', ': null,')
            .replaceAll(': NaN}', ': null}')
            .replaceAll(': NaN]', ': null]');
        
        print('🧹 Cleaned ${responseData.split('NaN').length - 1} NaN values from JSON');
        
        // Now parse the cleaned JSON
        final dynamic jsonData = jsonDecode(responseData);
        final List<dynamic> data = jsonData is List ? jsonData : jsonData['transactions'] ?? jsonData;
        
        final List<Transaction> transactions = [];
        int validCount = 0;
        int invalidCount = 0;
        
        for (int i = 0; i < data.length; i++) {
          try {
            final transaction = Transaction.fromJson(data[i]);
            transactions.add(transaction);
            validCount++;
          } catch (e) {
            invalidCount++;
            print('⚠️  Skipping transaction at index $i: $e');
          }
        }
        
        print('✅ Successfully parsed $validCount transactions, skipped $invalidCount broken entries');
        return transactions;
      } else {
        throw ApiException('Failed to fetch transactions', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      print('🚨 Unexpected error parsing transactions: $e');
      throw ApiException('Failed to parse transaction data: $e', 500);
    }
  }

  /// Get a specific transaction by ID
  Future<Transaction> getTransaction(String trxId) async {
    try {
      final response = await _dio.get('$baseUrl/transaction/$trxId');
      
      if (response.statusCode == 200) {
        return Transaction.fromJson(response.data);
      } else {
        throw ApiException('Transaction not found', response.statusCode ?? 404);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create a new transaction
  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final transactionData = transaction.toJson();
      // Remove fields that shouldn't be sent to the server
      transactionData.remove('id');
      transactionData.remove('created_at');
      transactionData.remove('updated_at');

      final response = await _dio.post(
        '$baseUrl/transaction',
        data: transactionData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Transaction.fromJson(response.data);
      } else {
        throw ApiException('Failed to create transaction', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Update an existing transaction
  Future<Transaction> updateTransaction(String trxId, Transaction transaction) async {
    try {
      final transactionData = transaction.toJson();
      // Remove fields that shouldn't be updated
      transactionData.remove('id');
      transactionData.remove('trx_id');
      transactionData.remove('created_at');
      
      final response = await _dio.put(
        '$baseUrl/api/v1/transactions/$trxId',
        data: transactionData,
      );

      if (response.statusCode == 200) {
        return Transaction.fromJson(response.data);
      } else {
        throw ApiException('Failed to update transaction', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String idOrTrxId) async {
    try {
      // Your API expects /transaction/<int:transaction_id>
      print('🔍 Attempting to parse ID: $idOrTrxId');
      final transactionId = int.tryParse(idOrTrxId);
      
      if (transactionId == null) {
        print('❌ Failed to parse ID as integer: $idOrTrxId');
        throw ApiException('Invalid transaction ID format: $idOrTrxId (API expects integer ID)', 400);
      }
      
      print('🗑️  Deleting transaction with ID: $transactionId via DELETE $baseUrl/transaction/$transactionId');
      final response = await _dio.delete('$baseUrl/transaction/$transactionId');
      
      print('🔍 Delete response: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Transaction $transactionId deleted successfully from API');
      } else {
        throw ApiException('Failed to delete transaction, status: ${response.statusCode}', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      print('🚨 DioException during delete: ${e.type}, ${e.message}');
      if (e.response != null) {
        print('🔍 Response status: ${e.response!.statusCode}');
        print('🔍 Response data: ${e.response!.data}');
      }
      throw _handleDioException(e);
    } catch (e) {
      print('🚨 Unexpected error during delete: $e');
      throw ApiException('Delete operation failed: $e', 500);
    }
  }

  /// Batch create multiple transactions
  Future<List<Transaction>> createTransactionBatch(List<Transaction> transactions) async {
    try {
      final transactionsData = transactions.map((t) {
        final data = t.toJson();
        data.remove('id');
        data.remove('created_at');
        data.remove('updated_at');
        return data;
      }).toList();

      final response = await _dio.post(
        '$baseUrl/api/v1/transactions/batch',
        data: {'transactions': transactionsData},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final List<dynamic> data = response.data['transactions'] ?? response.data;
        return data.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to create transaction batch', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Search transactions with text query
  Future<List<Transaction>> searchTransactions(String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
      };
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _dio.get(
        '$baseUrl/api/v1/transactions/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['transactions'] ?? response.data;
        return data.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to search transactions', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get transaction statistics/summary
  Future<TransactionSummary> getTransactionSummary({
    DateTime? fromDate,
    DateTime? toDate,
    String? accountIban,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String().split('T')[0];
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String().split('T')[0];
      if (accountIban != null) queryParams['account_iban'] = accountIban;

      final response = await _dio.get(
        '$baseUrl/api/v1/transactions/summary',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return TransactionSummary.fromJson(response.data);
      } else {
        throw ApiException('Failed to fetch transaction summary', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Upload receipt image for transaction processing
  Future<Transaction> uploadReceipt(String imagePath, {
    String? trxId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final formData = FormData.fromMap({
        'receipt': await MultipartFile.fromFile(imagePath),
        if (trxId != null) 'trx_id': trxId,
        if (metadata != null) 'metadata': metadata,
      });

      final response = await _dio.post(
        '$baseUrl/api/v1/transactions/receipt',
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Transaction.fromJson(response.data);
      } else {
        throw ApiException('Failed to process receipt', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Process voice input for transaction creation
  Future<Transaction> processVoiceInput(String audioPath, {
    String? language = 'en',
    Map<String, dynamic>? context,
  }) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(audioPath),
        'language': language,
        if (context != null) 'context': context,
      });

      final response = await _dio.post(
        '$baseUrl/api/v1/transactions/voice',
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Transaction.fromJson(response.data);
      } else {
        throw ApiException('Failed to process voice input', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Handle Dio exceptions and convert to custom exceptions
  ApiException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timeout', 408);
      case DioExceptionType.connectionError:
        return ApiException('No internet connection', 0);
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final message = e.response?.data?['message'] ?? 
                       e.response?.data?['error'] ?? 
                       'Request failed';
        return ApiException(message, statusCode);
      default:
        return ApiException('Network error: ${e.message}', 0);
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Transaction summary model for statistics
class TransactionSummary {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final int transactionCount;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final Map<String, double>? categoryBreakdown;
  final Map<String, int>? transactionsByType;

  const TransactionSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.transactionCount,
    this.periodStart,
    this.periodEnd,
    this.categoryBreakdown,
    this.transactionsByType,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['total_expenses'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transaction_count'] as int? ?? 0,
      periodStart: json['period_start'] != null 
          ? DateTime.parse(json['period_start'] as String)
          : null,
      periodEnd: json['period_end'] != null 
          ? DateTime.parse(json['period_end'] as String)
          : null,
      categoryBreakdown: json['category_breakdown'] != null
          ? Map<String, double>.from(
              (json['category_breakdown'] as Map).map(
                (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
              ),
            )
          : null,
      transactionsByType: json['transactions_by_type'] != null
          ? Map<String, int>.from(json['transactions_by_type'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_income': totalIncome,
      'total_expenses': totalExpenses,
      'balance': balance,
      'transaction_count': transactionCount,
      'period_start': periodStart?.toIso8601String(),
      'period_end': periodEnd?.toIso8601String(),
      'category_breakdown': categoryBreakdown,
      'transactions_by_type': transactionsByType,
    };
  }
}