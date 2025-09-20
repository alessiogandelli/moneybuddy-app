/// App-wide constants for MoneyBuddy
class AppConstants {
  // App Information
  static const String appName = 'MoneyBuddy';
  static const String appVersion = '1.0.0';
  static const String companyName = 'MoneyBuddy Inc.';
  
  // AI Assistant
  static const String assistantName = 'MoneyCA';
  static const String assistantFullName = 'MoneyBuddy Conversational Assistant';
  
  // API Configuration
  static const String baseApiUrl = 'https://api.moneybuddy.app';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Local Storage Keys
  static const String userProfileKey = 'user_profile';
  static const String transactionsKey = 'transactions';
  static const String insightsKey = 'insights';
  static const String preferencesKey = 'app_preferences';
  static const String onboardingCompleteKey = 'onboarding_complete';
  
  // Hive Box Names
  static const String userBox = 'user_box';
  static const String transactionBox = 'transaction_box';
  static const String categoryBox = 'category_box';
  static const String insightBox = 'insight_box';
  
  // Feature Flags
  static const bool enableVoiceInput = true;
  static const bool enableCameraCapture = true;
  static const bool enableOfflineMode = true;
  static const bool enableBiometrics = true;
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Transaction Categories (Default)
  static const List<String> defaultCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Investment',
    'Other',
  ];
  
  // User Segments for personalization
  static const String segmentSaver = 'saver';
  static const String segmentSpender = 'spender';
  static const String segmentInvestor = 'investor';
  static const String segmentBudgeter = 'budgeter';
  
  // Currency Configuration
  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxTransactionAmount = 1000000; // $1M
  static const int maxDescriptionLength = 200;
}