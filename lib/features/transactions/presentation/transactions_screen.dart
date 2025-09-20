import 'package:flutter/material.dart';

/// Transactions screen showing all user transactions
/// with options to add, edit, and categorize transactions
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.list)),
            Tab(text: 'Income', icon: Icon(Icons.trending_up)),
            Tab(text: 'Expenses', icon: Icon(Icons.trending_down)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter functionality
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList('all'),
          _buildTransactionList('income'),
          _buildTransactionList('expenses'),
        ],
      ),
    );
  }

  Widget _buildTransactionList(String type) {
    // Mock data for demonstration
    final List<MockTransaction> transactions = [
      MockTransaction(
        id: '1',
        description: 'Coffee Shop',
        amount: -4.50,
        category: 'Food & Dining',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'expense',
      ),
      MockTransaction(
        id: '2',
        description: 'Salary Deposit',
        amount: 3500.00,
        category: 'Income',
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: 'income',
      ),
      MockTransaction(
        id: '3',
        description: 'Grocery Store',
        amount: -78.34,
        category: 'Food & Dining',
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: 'expense',
      ),
    ];

    // Filter transactions based on type
    List<MockTransaction> filteredTransactions = transactions;
    if (type == 'income') {
      filteredTransactions = transactions.where((t) => t.type == 'income').toList();
    } else if (type == 'expenses') {
      filteredTransactions = transactions.where((t) => t.type == 'expense').toList();
    }

    if (filteredTransactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start tracking your finances!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(MockTransaction transaction) {
    final bool isExpense = transaction.amount < 0;
    final Color amountColor = isExpense ? Colors.red : Colors.green;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: amountColor.withOpacity(0.1),
          child: Icon(
            isExpense ? Icons.remove : Icons.add,
            color: amountColor,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${transaction.category} • ${_formatDate(transaction.date)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          '\$${transaction.amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          // TODO: Navigate to transaction detail
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transaction details for ${transaction.description}'),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

// Mock transaction class for demonstration
class MockTransaction {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final String type;

  MockTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
  });
}