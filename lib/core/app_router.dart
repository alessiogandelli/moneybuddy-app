import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/insights/presentation/insights_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import '../features/transactions/screens/add_transaction_screen.dart';
import '../features/transactions/presentation/transaction_details_screen.dart';
import '../features/moneyca_chat/presentation/chat_screen.dart';
import 'routes/app_routes.dart';

/// Simplified app router - directly to insights with floating chat
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/insights', // Start directly with insights
    debugLogDiagnostics: true,
    routes: [
      // Main Insights Route (home screen)
      GoRoute(
        path: '/insights',
        name: 'insights',
        builder: (context, state) => const InsightsScreen(),
      ),
      
      // Transactions Route (modal/sheet)
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        builder: (context, state) => const TransactionsScreen(),
        routes: [
          // Add Transaction Sub-route
          GoRoute(
            path: '/add',
            name: 'add-transaction',
            builder: (context, state) => const AddTransactionScreen(),
          ),
          // Individual Transaction Details
          GoRoute(
            path: '/:transactionId',
            name: 'transaction-details',
            builder: (context, state) {
              final transactionId = state.pathParameters['transactionId']!;
              return TransactionDetailsScreen(transactionId: transactionId);
            },
          ),
        ],
      ),
      
      // MoneyCA Chat Route (modal)
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0A0B0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0B0F),
        title: const Text('Oops!', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Page not found: ${state.uri.toString()}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/insights'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Back to Insights'),
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