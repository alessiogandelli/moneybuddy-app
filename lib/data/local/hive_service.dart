import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/transaction.dart';

/// Service for managing Hive local database
class HiveService {
  static const String _userBoxName = 'users';
  static const String _transactionsBoxName = 'transactions';
  static const String _settingsBoxName = 'settings';
  static const String _cacheBoxName = 'cache';

  /// Initialize Hive and register adapters
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register type adapters for custom objects
    // TODO: Add when dependencies are available
    // Hive.registerAdapter(UserAdapter());
    // Hive.registerAdapter(TransactionAdapter());
    // Hive.registerAdapter(CategoryAdapter());
    
    // Open boxes
    await Future.wait([
      Hive.openBox(_userBoxName),
      Hive.openBox(_transactionsBoxName),
      Hive.openBox(_settingsBoxName),
      Hive.openBox(_cacheBoxName),
    ]);
  }

  /// Check if all boxes are initialized
  static bool get isInitialized {
    return Hive.isBoxOpen(_userBoxName) &&
           Hive.isBoxOpen(_transactionsBoxName) &&
           Hive.isBoxOpen(_settingsBoxName) &&
           Hive.isBoxOpen(_cacheBoxName);
  }

  /// Ensure initialization before operations
  static Future<void> ensureInitialized() async {
    if (!isInitialized) {
      await init();
    }
  }

  /// Get user box for storing user data
  static Box get userBox {
    if (!Hive.isBoxOpen(_userBoxName)) {
      throw HiveError('User box not opened. Call HiveService.init() first.');
    }
    return Hive.box(_userBoxName);
  }

  /// Get transactions box for storing transactions
  static Box get transactionsBox {
    if (!Hive.isBoxOpen(_transactionsBoxName)) {
      throw HiveError('Transactions box not opened. Call HiveService.init() first.');
    }
    return Hive.box(_transactionsBoxName);
  }

  /// Get settings box for app settings
  static Box get settingsBox {
    if (!Hive.isBoxOpen(_settingsBoxName)) {
      throw HiveError('Settings box not opened. Call HiveService.init() first.');
    }
    return Hive.box(_settingsBoxName);
  }

  /// Get cache box for temporary data
  static Box get cacheBox {
    if (!Hive.isBoxOpen(_cacheBoxName)) {
      throw HiveError('Cache box not opened. Call HiveService.init() first.');
    }
    return Hive.box(_cacheBoxName);
  }

  /// Save user data locally
  static Future<void> saveUser(User user) async {
    await ensureInitialized();
    await userBox.put('current_user', user.toJson());
  }

  /// Get current user from local storage
  static User? getCurrentUser() {
    if (!isInitialized) return null;
    
    final userData = userBox.get('current_user');
    return userData != null ? User.fromJson(Map<String, dynamic>.from(userData)) : null;
  }

  /// Save transactions locally for offline access
  static Future<void> saveTransactions(List<Transaction> transactions) async {
    await ensureInitialized();
    final transactionsData = transactions.map((t) => t.toJson()).toList();
    await transactionsBox.put('transactions', transactionsData);
  }

  /// Get cached transactions
  static List<Transaction> getCachedTransactions() {
    if (!isInitialized) return [];
    
    final transactionsData = transactionsBox.get('transactions', defaultValue: <dynamic>[]);
    final List<Transaction> validTransactions = [];
    int skippedCount = 0;
    
    for (int i = 0; i < (transactionsData as List).length; i++) {
      try {
        final transactionJson = Map<String, dynamic>.from(transactionsData[i] as Map);
        final transaction = Transaction.fromJson(transactionJson);
        validTransactions.add(transaction);
      } catch (e) {
        skippedCount++;
        print('⚠️  Skipping broken transaction at index $i: $e');
        // Continue processing other transactions
      }
    }
    
    if (skippedCount > 0) {
      print('📊 Loaded ${validTransactions.length} valid transactions, skipped $skippedCount broken entries');
    } else {
      print('✅ Loaded ${validTransactions.length} transactions successfully');
    }
    
    return validTransactions;
  }

  /// Save app settings
  static Future<void> saveSetting(String key, dynamic value) async {
    await ensureInitialized();
    await settingsBox.put(key, value);
  }

  /// Get app setting
  static T? getSetting<T>(String key, {T? defaultValue}) {
    if (!isInitialized) return defaultValue;
    
    return settingsBox.get(key, defaultValue: defaultValue);
  }

  /// Cache data with expiration
  static Future<void> cacheData(String key, dynamic data, {Duration? expiration}) async {
    await ensureInitialized();
    final cacheEntry = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiration': expiration?.inMilliseconds,
    };
    await cacheBox.put(key, cacheEntry);
  }

  /// Get cached data if not expired
  static T? getCachedData<T>(String key) {
    if (!isInitialized) return null;
    
    final cacheEntry = cacheBox.get(key);
    if (cacheEntry == null) return null;

    final entry = Map<String, dynamic>.from(cacheEntry);
    final timestamp = entry['timestamp'] as int;
    final expiration = entry['expiration'] as int?;

    if (expiration != null) {
      final expiryTime = timestamp + expiration;
      if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
        // Data expired, remove it
        cacheBox.delete(key);
        return null;
      }
    }

    return entry['data'] as T?;
  }

  /// Clear all cached data
  static Future<void> clearCache() async {
    await ensureInitialized();
    await cacheBox.clear();
  }

  /// Clear all user data (for logout)
  static Future<void> clearUserData() async {
    await ensureInitialized();
    await Future.wait([
      userBox.clear(),
      transactionsBox.clear(),
    ]);
  }

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
  }
}