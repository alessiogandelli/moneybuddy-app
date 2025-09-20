import 'package:flutter/material.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/services/transaction_api_service.dart';
import '../../../data/models/transaction.dart';

/// Transactions screen showing all user transactions from your API
/// with options to add, edit, and categorize transactions
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TransactionRepository _repository;
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _repository = TransactionRepository(
      apiService: TransactionApiService(),
      useMockData: false, // Force real API
    );
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _repository.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      print('🔄 Loading transactions from http://localhost:420/transaction');
      final transactions = await _repository.getTransactions(forceRefresh: true);
      
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
      
      print('✅ Loaded ${transactions.length} transactions successfully');
    } catch (e) {
      print('🚨 Error loading transactions: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
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
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading transactions from your database...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load transactions',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error: $_error',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTransactions,
                        child: const Text('Retry'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          print('🔍 Debug info:');
                          print('  - API URL: http://localhost:420/transaction');
                          print('  - Error: $_error');
                          print('  - Is API running? Check your terminal');
                        },
                        child: const Text('Debug Info'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
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
    // Debug: Print sample transaction to understand data structure
    if (_transactions.isNotEmpty && type == 'all') {
      final sample = _transactions.first;
      print('📊 Sample transaction: direction=${sample.direction}, amount=${sample.amount}, merchant=${sample.merchantName}');
    }
    
    // Filter transactions based on type from your API data
    List<Transaction> filteredTransactions = _transactions;
    if (type == 'income') {
      // Income: Credit direction OR positive amount (but prioritize direction)
      filteredTransactions = _transactions.where((t) {
        final direction = t.direction.toLowerCase();
        if (direction == 'credit' || direction == 'in') {
          return true; // Definitely income based on direction
        }
        // Only use amount if direction is unclear AND amount is positive
        if (direction != 'debit' && direction != 'out' && t.amount > 0) {
          return true;
        }
        return false;
      }).toList();
    } else if (type == 'expenses') {
      // Expenses: Debit direction OR negative amount (but prioritize direction)
      filteredTransactions = _transactions.where((t) {
        final direction = t.direction.toLowerCase();
        if (direction == 'debit' || direction == 'out') {
          return true; // Definitely expense based on direction
        }
        // Only use amount if direction is unclear AND amount is negative
        if (direction != 'credit' && direction != 'in' && t.amount < 0) {
          return true;
        }
        return false;
      }).toList();
    }

    print('📊 Filtered ${filteredTransactions.length} transactions for $type (total: ${_transactions.length})');

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              type == 'all' ? 'No transactions found' : 'No $type transactions',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your API or add some transactions!',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTransactions,
              child: const Text('Refresh'),
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

  Widget _buildTransactionCard(Transaction transaction) {
    final bool isExpense = transaction.amount < 0 || 
                          transaction.direction.toLowerCase() == 'debit' ||
                          transaction.direction.toLowerCase() == 'out';
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
          transaction.merchantName ?? transaction.trxId,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.merchantFullText != null)
              Text(
                transaction.merchantFullText!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              '${transaction.currency} • ${transaction.direction.toUpperCase()} • ${_formatDate(transaction.bookingDate ?? transaction.createdAt)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.currency} ${transaction.amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (transaction.trxType != null)
              Text(
                transaction.trxType!,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
              ),
          ],
        ),
        onTap: () {
          // Show transaction details
          _showTransactionDetails(transaction);
        },
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('ID', transaction.trxId),
            _buildDetailRow('Amount', '${transaction.currency} ${transaction.amount.toStringAsFixed(2)}'),
            _buildDetailRow('Direction', transaction.direction.toUpperCase()),
            if (transaction.merchantName != null)
              _buildDetailRow('Merchant', transaction.merchantName!),
            if (transaction.accountIban != null)
              _buildDetailRow('Account', transaction.accountIban!),
            if (transaction.trxType != null)
              _buildDetailRow('Type', transaction.trxType!),
            _buildDetailRow('Date', transaction.bookingDate?.toString() ?? transaction.createdAt.toString()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}