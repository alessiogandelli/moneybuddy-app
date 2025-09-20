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

  /// Get user box for storing user data
  static Box get userBox => Hive.box(_userBoxName);

  /// Get transactions box for storing transactions
  static Box get transactionsBox => Hive.box(_transactionsBoxName);

  /// Get settings box for app settings
  static Box get settingsBox => Hive.box(_settingsBoxName);

  /// Get cache box for temporary data
  static Box get cacheBox => Hive.box(_cacheBoxName);

  /// Save user data locally
  static Future<void> saveUser(User user) async {
    await userBox.put('current_user', user.toJson());
  }

  /// Get current user from local storage
  static User? getCurrentUser() {
    final userData = userBox.get('current_user');
    return userData != null ? User.fromJson(Map<String, dynamic>.from(userData)) : null;
  }

  /// Save transactions locally for offline access
  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final transactionsData = transactions.map((t) => t.toJson()).toList();
    await transactionsBox.put('transactions', transactionsData);
  }

  /// Get cached transactions
  static List<Transaction> getCachedTransactions() {
    final transactionsData = transactionsBox.get('transactions', defaultValue: <dynamic>[]);
    return (transactionsData as List)
        .map((data) => Transaction.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }

  /// Save app settings
  static Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  /// Get app setting
  static T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue);
  }

  /// Cache data with expiration
  static Future<void> cacheData(String key, dynamic data, {Duration? expiration}) async {
    final cacheEntry = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiration': expiration?.inMilliseconds,
    };
    await cacheBox.put(key, cacheEntry);
  }

  /// Get cached data if not expired
  static T? getCachedData<T>(String key) {
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
    await cacheBox.clear();
  }

  /// Clear all user data (for logout)
  static Future<void> clearUserData() async {
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