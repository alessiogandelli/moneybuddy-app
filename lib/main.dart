import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/app_router.dart';

void main() {
  runApp(const MoneyBuddyApp());
}

/// Main MoneyBuddy Application
class MoneyBuddyApp extends StatelessWidget {
  const MoneyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MoneyBuddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
