// import 'package:equatable/equatable.dart';
// import 'package:json_annotation/json_annotation.dart';
// import 'package:hive/hive.dart';

// TODO: Uncomment when dependencies are installed
// part 'user.g.dart';

// @JsonSerializable()
// @HiveType(typeId: 0)
/// User model representing the app user's profile and preferences
class User {
  // @HiveField(0)
  final String id;
  
  // @HiveField(1)
  final String name;
  
  // @HiveField(2)
  final String email;
  
  // @HiveField(3)
  final String? avatarUrl;
  
  // @HiveField(4)
  final UserSegment segment;
  
  // @HiveField(5)
  final Map<String, dynamic> preferences;
  
  // @HiveField(6)
  final DateTime createdAt;
  
  // @HiveField(7)
  final DateTime updatedAt;
  
  // @HiveField(8)
  final bool onboardingCompleted;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.segment,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
    this.onboardingCompleted = false,
  });

  /// Create user from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      segment: UserSegment.values.firstWhere(
        (e) => e.name == json['segment'],
        orElse: () => UserSegment.budgeter,
      ),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
    );
  }
  
  /// Convert user to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'segment': segment.name,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'onboardingCompleted': onboardingCompleted,
    };
  }

  /// Copy user with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    UserSegment? segment,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? onboardingCompleted,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      segment: segment ?? this.segment,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  // TODO: Implement proper equality when Equatable is available
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode;
}

/// User segment for personalized experience
// @HiveType(typeId: 1)
enum UserSegment {
  // @HiveField(0)
  saver,
  
  // @HiveField(1)
  spender,
  
  // @HiveField(2)
  investor,
  
  // @HiveField(3)
  budgeter,
}

/// Extension for UserSegment display
extension UserSegmentExtension on UserSegment {
  String get displayName {
    switch (this) {
      case UserSegment.saver:
        return 'Saver';
      case UserSegment.spender:
        return 'Spender';
      case UserSegment.investor:
        return 'Investor';
      case UserSegment.budgeter:
        return 'Budgeter';
    }
  }

  String get description {
    switch (this) {
      case UserSegment.saver:
        return 'Focused on building savings and emergency funds';
      case UserSegment.spender:
        return 'Enjoys spending but wants to track and optimize';
      case UserSegment.investor:
        return 'Interested in growing wealth through investments';
      case UserSegment.budgeter:
        return 'Prefers detailed budgeting and expense control';
    }
  }
}