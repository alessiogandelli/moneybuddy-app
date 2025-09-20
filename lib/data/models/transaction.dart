// import 'package:json_annotation/json_annotation.dart';
// import 'package:hive/hive.dart';

// TODO: Uncomment when dependencies are installed
// part 'transaction.g.dart';

// @JsonSerializable()
// @HiveType(typeId: 2)
/// Transaction model representing financial transactions
class Transaction {
  // @HiveField(0)
  final String id;
  
  // @HiveField(1)
  final String description;
  
  // @HiveField(2)
  final double amount;
  
  // @HiveField(3)
  final String category;
  
  // @HiveField(4)
  final TransactionType type;
  
  // @HiveField(5)
  final DateTime date;
  
  // @HiveField(6)
  final String? notes;
  
  // @HiveField(7)
  final String? receiptUrl;
  
  // @HiveField(8)
  final String? location;
  
  // @HiveField(9)
  final Map<String, dynamic>? metadata;
  
  // @HiveField(10)
  final DateTime createdAt;
  
  // @HiveField(11)
  final DateTime updatedAt;
  
  // @HiveField(12)
  final String userId;

  const Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.notes,
    this.receiptUrl,
    this.location,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  /// Create transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      location: json['location'] as String?,
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as String,
    );
  }
  
  /// Convert transaction to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'type': type.name,
      'date': date.toIso8601String(),
      'notes': notes,
      'receiptUrl': receiptUrl,
      'location': location,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
    };
  }

  /// Copy transaction with updated fields
  Transaction copyWith({
    String? id,
    String? description,
    double? amount,
    String? category,
    TransactionType? type,
    DateTime? date,
    String? notes,
    String? receiptUrl,
    String? location,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  /// Check if transaction is an expense (negative amount or expense type)
  bool get isExpense => amount < 0 || type == TransactionType.expense;

  /// Check if transaction is income (positive amount and income type)
  bool get isIncome => amount > 0 && type == TransactionType.income;

  /// Get absolute amount for display
  double get absoluteAmount => amount.abs();

  /// Get formatted amount string
  String get formattedAmount {
    final absAmount = absoluteAmount;
    return '\$${absAmount.toStringAsFixed(2)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.amount == amount &&
        other.description == description &&
        other.date == date;
  }

  @override
  int get hashCode => id.hashCode ^ amount.hashCode ^ description.hashCode ^ date.hashCode;
}

/// Transaction type enumeration
// @HiveType(typeId: 3)
enum TransactionType {
  // @HiveField(0)
  income,
  
  // @HiveField(1)
  expense,
  
  // @HiveField(2)
  transfer,
}

/// Extension for TransactionType display
extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }

  String get symbol {
    switch (this) {
      case TransactionType.income:
        return '+';
      case TransactionType.expense:
        return '-';
      case TransactionType.transfer:
        return '↔';
    }
  }
}