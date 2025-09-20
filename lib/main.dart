import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/app_router.dart';
import 'data/local/hive_service.dart';

void main() async {
  // Ensure Flutter framework is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await HiveService.init();
  
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
