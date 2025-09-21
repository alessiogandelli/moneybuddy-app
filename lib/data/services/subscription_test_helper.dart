import 'package:flutter/material.dart';
import 'subscription_demo_service.dart';

/// Quick test function to verify subscription detection
/// Call this from main() or any widget to test the functionality
void testSubscriptionFeature() {
  print('🧪 Testing Subscription Detection Feature...\n');
  
  try {
    // Generate sample data and test detection
    final summary = SubscriptionDemoService.testSubscriptionDetection();
    
    print('\n✅ Subscription detection test completed successfully!');
    print('📋 Summary:');
    print('   • Active subscriptions: ${summary.activeCount}');
    print('   • Monthly total: CHF ${summary.totalMonthlyAmount.toStringAsFixed(2)}');
    print('   • Yearly total: CHF ${summary.totalYearlyAmount.toStringAsFixed(2)}');
    
    if (summary.subscriptions.isNotEmpty) {
      print('\n📱 Detected subscriptions:');
      for (final sub in summary.subscriptions) {
        print('   ${sub.icon} ${sub.name} - CHF ${sub.amount.toStringAsFixed(2)} (${sub.frequency.displayName})');
      }
    }
    
  } catch (e, stackTrace) {
    print('❌ Test failed with error: $e');
    print('Stack trace: $stackTrace');
  }
}

/// Widget to display test results in the UI
class SubscriptionTestWidget extends StatelessWidget {
  const SubscriptionTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.science, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Test Subscription Detection',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              testSubscriptionFeature();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Check console/debug output for test results'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Run Test'),
          ),
          const SizedBox(height: 8),
          const Text(
            'This will generate sample subscription data and test the detection algorithm. Check the debug console for results.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}