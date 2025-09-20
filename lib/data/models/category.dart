// import 'package:json_annotation/json_annotation.dart';
// import 'package:hive/hive.dart';

// TODO: Uncomment when dependencies are installed
// part 'category.g.dart';

// @JsonSerializable()
// @HiveType(typeId: 4)
/// Category model for organizing transactions
class Category {
  // @HiveField(0)
  final String id;
  
  // @HiveField(1)
  final String name;
  
  // @HiveField(2)
  final String? description;
  
  // @HiveField(3)
  final String icon;
  
  // @HiveField(4)
  final String color;
  
  // @HiveField(5)
  final CategoryType type;
  
  // @HiveField(6)
  final double? budgetLimit;
  
  // @HiveField(7)
  final bool isActive;
  
  // @HiveField(8)
  final DateTime createdAt;
  
  // @HiveField(9)
  final String userId;

  const Category({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    required this.type,
    this.budgetLimit,
    this.isActive = true,
    required this.createdAt,
    required this.userId,
  });

  /// Create category from JSON
  // factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  
  /// Convert category to JSON
  // Map<String, dynamic> toJson() => _$CategoryToJson(this);

  /// Copy category with updated fields
  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    CategoryType? type,
    double? budgetLimit,
    bool? isActive,
    DateTime? createdAt,
    String? userId,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.userId == userId;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ userId.hashCode;
}

/// Category type enumeration
// @HiveType(typeId: 5)
enum CategoryType {
  // @HiveField(0)
  expense,
  
  // @HiveField(1)
  income,
  
  // @HiveField(2)
  both,
}

/// Extension for CategoryType display
extension CategoryTypeExtension on CategoryType {
  String get displayName {
    switch (this) {
      case CategoryType.expense:
        return 'Expense';
      case CategoryType.income:
        return 'Income';
      case CategoryType.both:
        return 'Both';
    }
  }
}

/// Default categories for new users
class DefaultCategories {
  static List<Category> get expenseCategories => [
    Category(
      id: 'food_dining',
      name: 'Food & Dining',
      description: 'Restaurants, groceries, coffee',
      icon: '🍽️',
      color: '#FF5722',
      type: CategoryType.expense,
      createdAt: DateTime.now(),
      userId: 'default',
    ),
    Category(
      id: 'transportation',
      name: 'Transportation',
      description: 'Gas, public transport, rideshare',
      icon: '🚗',
      color: '#2196F3',
      type: CategoryType.expense,
      createdAt: DateTime.now(),
      userId: 'default',
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      description: 'Clothes, electronics, general shopping',
      icon: '🛍️',
      color: '#9C27B0',
      type: CategoryType.expense,
      createdAt: DateTime.now(),
      userId: 'default',
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      description: 'Movies, games, hobbies',
      icon: '🎮',
      color: '#E91E63',
      type: CategoryType.expense,
      createdAt: DateTime.now(),
      userId: 'default',
    ),
    Category(
      id: 'bills_utilities',
      name: 'Bills & Utilities',
      description: 'Electricity, water, internet, phone',
      icon: '💡',
      color: '#FF9800',
      type: CategoryType.expense,
      createdAt: DateTime.now(),
      userId: 'default',
    ),
    Category(
      id: 'healthcare',
      name: 'Healthcare',
      description: 'Medical, dental, pharmacy',
      icon: '⚕️',
      color: '#4CAF50',
      type: CategoryType.expense,
      createdAt: DateTime.now(),
      userId: 'default',
    ),
  ];

  static List<Category> get incomeCategories => [
    Category(
      id: 'salary',
      name: 'Salary',
      description: 'Primary job income',
      icon: '💼',
      color: '#4CAF50',
      type: CategoryType.income,
      createdAt: DateTime.now(),
      userId: 'default',
    ),
    Category(
      id: 'freelance',
      name: 'Freelance',
      description: 'Freelance and contract work',
      icon: '💻',
      color: '#607D8B',
      type: CategoryType.income,
      createdAt: DateTime.now(),
      userId: 'default',
    ),
    Category(
      id: 'investment',
      name: 'Investment',
      description: 'Dividends, capital gains',
      icon: '📈',
      color: '#3F51B5',
      type: CategoryType.income,
      createdAt: DateTime.now(),
      userId: 'default',
    ),
  ];

  static List<Category> get allDefault => [
    ...expenseCategories,
    ...incomeCategories,
  ];
}