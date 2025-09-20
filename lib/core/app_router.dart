import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import '../features/transactions/screens/add_transaction_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import '../features/moneyca_chat/presentation/chat_screen.dart';
import '../shared/widgets/main_navigation.dart';
import 'routes/app_routes.dart';

/// App router configuration using go_router
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.onboarding, // Start with onboarding for new users
    debugLogDiagnostics: true,
    routes: [
      // Onboarding Routes
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Main App Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          // Home/Dashboard Route
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const DashboardScreen(),
          ),
          
          // Transactions Route
          GoRoute(
            path: AppRoutes.transactions,
            name: 'transactions',
            builder: (context, state) => const TransactionsScreen(),
            routes: [
              GoRoute(
                path: '/add',
                name: 'add-transaction',
                builder: (context, state) => const AddTransactionScreen(),
              ),
            ],
          ),
          
          // Insights Route
          GoRoute(
            path: AppRoutes.insights,
            name: 'insights',
            builder: (context, state) => const InsightsScreen(),
          ),
          
          // MoneyCA Chat Route
          GoRoute(
            path: AppRoutes.chat,
            name: 'chat',
            builder: (context, state) => const ChatScreen(),
          ),
        ],
      ),
      
      // Profile & Settings Routes (outside of shell)
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri.toString()}',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;
}

// Placeholder screens that will be implemented later
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyBuddy Dashboard'),
        actions: [
          // Debug menu for development
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'onboarding':
                  context.go(AppRoutes.onboarding);
                  break;
                case 'profile':
                  context.push(AppRoutes.profile);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'onboarding',
                child: ListTile(
                  leading: Icon(Icons.psychology),
                  title: Text('Reset Onboarding'),
                  subtitle: Text('For development'),
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Welcome to MoneyBuddy!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your AI-powered financial assistant',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 32),
            Text('🚧 Dashboard coming soon!'),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('🚧 Profile screen coming soon!'),
      ),
    );
  }
}