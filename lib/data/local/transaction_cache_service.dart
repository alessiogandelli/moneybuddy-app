import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

/// Service for caching transactions locally with Hive
class TransactionCacheService {
  static const String _boxName = 'transactions_cache';
  static const String _timestampKey = 'cache_timestamp';
  static const Duration _cacheValidDuration = Duration(hours: 1); // Cache valid for 1 hour
  
  static Box<Transaction>? _box;
  static Box? _metaBox;
  
  /// Initialize the cache service
  static Future<void> initialize() async {
    // Register transaction adapter if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<Transaction>(_boxName);
    } else {
      _box = Hive.box<Transaction>(_boxName);
    }
    
    if (!Hive.isBoxOpen('${_boxName}_meta')) {
      _metaBox = await Hive.openBox('${_boxName}_meta');
    } else {
      _metaBox = Hive.box('${_boxName}_meta');
    }
  }
  
  /// Check if cached transactions are still valid
  static bool isCacheValid() {
    if (_metaBox == null) return false;
    
    final timestamp = _metaBox!.get(_timestampKey);
    if (timestamp == null) return false;
    
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    return now.difference(cacheTime) < _cacheValidDuration;
  }
  
  /// Cache transactions
  static Future<void> cacheTransactions(List<Transaction> transactions) async {
    if (_box == null || _metaBox == null) await initialize();
    
    // Clear existing cache
    await _box!.clear();
    
    // Store transactions with their ID as key
    for (final transaction in transactions) {
      final key = transaction.id?.toString() ?? transaction.trxId ?? 'unknown_${transactions.indexOf(transaction)}';
      await _box!.put(key, transaction);
    }
    
    // Update timestamp
    await _metaBox!.put(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    
    print('💾 Cached ${transactions.length} transactions');
  }
  
  /// Get cached transactions
  static List<Transaction>? getCachedTransactions() {
    if (_box == null || !isCacheValid()) return null;
    
    try {
      final transactions = _box!.values.toList();
      print('📱 Retrieved ${transactions.length} cached transactions');
      return transactions;
    } catch (e) {
      print('⚠️ Error reading cached transactions: $e');
      return null;
    }
  }
  
  /// Add or update a single transaction in cache
  static Future<void> addTransaction(Transaction transaction) async {
    if (_box == null) await initialize();
    
    final key = transaction.id?.toString() ?? transaction.trxId;
    await _box!.put(key, transaction);
    print('💾 Added/updated transaction in cache: $key');
  }
  
  /// Remove a transaction from cache
  static Future<void> removeTransaction(String idOrTrxId) async {
    if (_box == null) await initialize();
    
    await _box!.delete(idOrTrxId);
    print('🗑️ Removed transaction from cache: $idOrTrxId');
  }
  
  /// Clear all cached transactions
  static Future<void> clearCache() async {
    if (_box == null) await initialize();
    
    await _box!.clear();
    await _metaBox!.delete(_timestampKey);
    print('🗑️ Cleared transaction cache');
  }
  
  /// Get cached transaction count
  static int getCachedTransactionCount() {
    if (_box == null) return 0;
    return _box!.length;
  }
}

/// Hive adapter for Transaction model
class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 0;

  @override
  Transaction read(BinaryReader reader) {
    final fields = <String, dynamic>{};
    final numFields = reader.readByte();
    
    for (int i = 0; i < numFields; i++) {
      final key = reader.readString();
      final value = reader.read();
      fields[key] = value;
    }
    
    return Transaction.fromJson(fields);
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    final json = obj.toJson();
    writer.writeByte(json.length);
    
    for (final entry in json.entries) {
      writer.writeString(entry.key);
      writer.write(entry.value);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}