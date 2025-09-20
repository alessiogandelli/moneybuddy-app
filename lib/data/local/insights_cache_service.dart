import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import '../services/insights_service.dart';

/// Service for caching insights data locally with Hive
class InsightsCacheService {
  static const String _boxName = 'insights_cache';
  static const String _summaryKey = 'spending_summary';
  static const String _categoriesKey = 'categories';
  static const String _insightsKey = 'insights';
  static const String _timestampKey = 'cache_timestamp';
  static const String _periodKey = 'cached_period';
  
  static const Duration _cacheValidDuration = Duration(hours: 6); // Cache valid for 6 hours
  
  static Box? _box;
  
  /// Initialize the cache service
  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
  }
  
  /// Check if cached insights are still valid for the given period
  static bool isCacheValid(String period) {
    if (_box == null) return false;
    
    final cachedPeriod = _box!.get(_periodKey);
    final timestamp = _box!.get(_timestampKey);
    
    if (cachedPeriod != period || timestamp == null) return false;
    
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    return now.difference(cacheTime) < _cacheValidDuration;
  }
  
  /// Cache insights data
  static Future<void> cacheInsights({
    required String period,
    required SpendingSummary summary,
    required List<CategoryData> categories,
    required List<InsightItem> insights,
  }) async {
    if (_box == null) await initialize();
    
    // Convert data to JSON for storage
    await _box!.putAll({
      _periodKey: period,
      _timestampKey: DateTime.now().millisecondsSinceEpoch,
      _summaryKey: _summaryToJson(summary),
      _categoriesKey: _categoriesToJson(categories),
      _insightsKey: _insightsToJson(insights),
    });
    
    print('💾 Cached insights for period: $period');
  }
  
  /// Get cached insights data
  static CachedInsights? getCachedInsights(String period) {
    if (_box == null || !isCacheValid(period)) return null;
    
    try {
      final summaryJson = _box!.get(_summaryKey);
      final categoriesJson = _box!.get(_categoriesKey);
      final insightsJson = _box!.get(_insightsKey);
      
      if (summaryJson == null || categoriesJson == null || insightsJson == null) {
        return null;
      }
      
      return CachedInsights(
        summary: _summaryFromJson(summaryJson),
        categories: _categoriesFromJson(categoriesJson),
        insights: _insightsFromJson(insightsJson),
      );
    } catch (e) {
      print('⚠️ Error reading cached insights: $e');
      return null;
    }
  }
  
  /// Clear all cached insights
  static Future<void> clearCache() async {
    if (_box == null) await initialize();
    await _box!.clear();
    print('🗑️ Cleared insights cache');
  }
  
  /// Clear cache for specific period
  static Future<void> clearCacheForPeriod(String period) async {
    final cachedPeriod = _box?.get(_periodKey);
    if (cachedPeriod == period) {
      await clearCache();
    }
  }
  
  // JSON conversion helpers
  static Map<String, dynamic> _summaryToJson(SpendingSummary summary) {
    return {
      'totalIncome': summary.totalIncome,
      'totalExpenses': summary.totalExpenses,
      'savingsRate': summary.savingsRate,
      'transactionCount': summary.transactionCount,
    };
  }
  
  static SpendingSummary _summaryFromJson(Map<dynamic, dynamic> json) {
    return SpendingSummary(
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      savingsRate: (json['savingsRate'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transactionCount'] as int? ?? 0,
    );
  }
  
  static List<Map<String, dynamic>> _categoriesToJson(List<CategoryData> categories) {
    return categories.map((category) => {
      'name': category.name,
      'amount': category.amount,
      'colorValue': category.color.value,
    }).toList();
  }
  
  static List<CategoryData> _categoriesFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => CategoryData(
      json['name'] as String,
      (json['amount'] as num).toDouble(),
      Color(json['colorValue'] as int),
    )).toList();
  }
  
  static List<Map<String, dynamic>> _insightsToJson(List<InsightItem> insights) {
    return insights.map((insight) => {
      'emoji': insight.emoji,
      'title': insight.title,
      'description': insight.description,
      'colorValue': insight.color.value,
    }).toList();
  }
  
  static List<InsightItem> _insightsFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => InsightItem(
      emoji: json['emoji'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      color: Color(json['colorValue'] as int),
    )).toList();
  }
}

/// Container for cached insights data
class CachedInsights {
  final SpendingSummary summary;
  final List<CategoryData> categories;
  final List<InsightItem> insights;
  
  const CachedInsights({
    required this.summary,
    required this.categories,
    required this.insights,
  });
}