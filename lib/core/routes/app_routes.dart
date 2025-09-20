/// Route constants for navigation
class AppRoutes {
  // Onboarding Routes
  static const String onboarding = '/onboarding';
  static const String onboardingWelcome = '/onboarding/welcome';
  static const String onboardingPersonalization = '/onboarding/personalization';
  static const String onboardingGoals = '/onboarding/goals';
  static const String onboardingComplete = '/onboarding/complete';
  
  // Authentication Routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  
  // Main App Routes
  static const String home = '/';
  static const String dashboard = '/dashboard';
  
  // Transaction Routes
  static const String transactions = '/transactions';
  static const String addTransaction = '/transactions/add';
  static const String editTransaction = '/transactions/edit';
  static const String transactionDetail = '/transactions/detail';
  static const String transactionCamera = '/transactions/camera';
  
  // Insights Routes
  static const String insights = '/insights';
  static const String spendingAnalysis = '/insights/spending';
  static const String budgetOverview = '/insights/budget';
  static const String financialGoals = '/insights/goals';
  
  // MoneyCA Chat Routes
  static const String chat = '/chat';
  static const String chatHistory = '/chat/history';
  
  // Profile & Settings Routes
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String preferences = '/settings/preferences';
  static const String security = '/settings/security';
  static const String help = '/help';
  static const String about = '/about';
  
  // Utility function to generate transaction detail route with ID
  static String transactionDetailWithId(String transactionId) {
    return '$transactionDetail/$transactionId';
  }
  
  // Utility function to generate edit transaction route with ID
  static String editTransactionWithId(String transactionId) {
    return '$editTransaction/$transactionId';
  }
}