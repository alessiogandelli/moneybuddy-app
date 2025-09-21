import 'package:flutter/material.dart';
import '../../../core/theme/style.dart';
import '../../../data/services/insights_service.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/services/transaction_api_service.dart';
import '../../../data/local/insights_cache_service.dart';
import '../../../data/models/transaction.dart';
import '../../../shared/widgets/chat_overlay.dart';
import 'package:go_router/go_router.dart';

/// Insights screen showing spending patterns, trends, and financial analysis
/// powered by AI to help users understand their financial behavior
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String selectedPeriod = 'This Month';
  
  final List<String> periods = [
    'This Week',
    'This Month', 
    'Last 3 Months',
    'This Year',
  ];

  final TransactionRepository _repository = TransactionRepository(
    apiService: TransactionApiService(),
  );
  
  SpendingSummary? _summary;
  List<CategoryData> _categories = [];
  List<InsightItem> _insights = [];
  List<Transaction> _recentTransactions = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _showChatOverlay = false;

  @override
  void initState() {
    super.initState();
    _loadTransactionData();
  }

  Future<void> _loadTransactionData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dateRange = InsightsService.getDateRangeForPeriod(selectedPeriod);
      
      // Always fetch transactions first for recent display
      final transactions = await _repository.getTransactions();
      
      // Store recent transactions for display
      _recentTransactions = transactions.take(5).toList();
      
      // Try to load from cache first for insights calculations
      final cachedData = InsightsCacheService.getCachedInsights(selectedPeriod);
      if (cachedData != null) {
        setState(() {
          _summary = cachedData.summary;
          _categories = cachedData.categories;
          _insights = cachedData.insights;
          _isLoading = false;
        });
        return;
      }
      
      final summary = InsightsService.calculateSpendingSummary(
        transactions, 
        startDate: dateRange.start, 
        endDate: dateRange.end,
      );
      
      final categories = InsightsService.calculateCategoryBreakdown(
        transactions, 
        startDate: dateRange.start, 
        endDate: dateRange.end,
      );
      
      final insights = InsightsService.generateInsights(
        transactions, 
        startDate: dateRange.start, 
        endDate: dateRange.end,
      );

      // Cache the fresh data
      await InsightsCacheService.cacheInsights(
        period: selectedPeriod,
        summary: summary,
        categories: categories,
        insights: insights,
      );

      setState(() {
        _summary = summary;
        _categories = categories;
        _insights = insights;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading transaction data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    
    // Clear cache and reload
    await InsightsCacheService.clearCache();
    await _loadTransactionData();
    
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppStyle.darkBackground,
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppStyle.primaryGreen, AppStyle.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppStyle.primaryGreen.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showChatOverlay = true;
                });
              },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppStyle.darkBackground,
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppStyle.greenAccent,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: AppStyle.greenAccent.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Money Story',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Cool refresh button with subtle animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: IconButton(
              onPressed: _isRefreshing ? null : _refreshData,
              icon: AnimatedRotation(
                turns: _isRefreshing ? 1 : 0,
                duration: const Duration(milliseconds: 1000),
                child: Icon(
                  Icons.refresh_rounded,
                  color: _isRefreshing ? Colors.grey : Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          // Revolutionary period selector
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [AppStyle.primaryGreen.withOpacity(0.2), AppStyle.greenAccent.withOpacity(0.2)],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  selectedPeriod = value;
                });
                _loadTransactionData();
              },
              itemBuilder: (context) => periods.map((period) => 
                PopupMenuItem(
                  value: period, 
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: period == selectedPeriod 
                        ? AppStyle.primaryGreen.withOpacity(0.3) 
                        : Colors.transparent,
                    ),
                    child: Text(
                      period,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ).toList(),
              color: AppStyle.cardBackground,
              elevation: 20,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedPeriod,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppStyle.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppStyle.primaryGreen),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Analyzing your money story...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : _buildRevolutionaryInsightsUI(),
        ),
        // Chat overlay
        if (_showChatOverlay)
          ChatOverlay(
            onClose: () {
              setState(() {
                _showChatOverlay = false;
              });
            },
          ),
      ],
    );
  }

  Widget _buildRevolutionaryInsightsUI() {
    return CustomScrollView(
      slivers: [
        // Hero Section with stunning visuals
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(20),
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppStyle.primaryGreen.withOpacity(0.8),
                  AppStyle.greenAccent.withOpacity(0.6),
                  AppStyle.stateSuccess70.withOpacity(0.4),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppStyle.primaryGreen.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Animated background pattern
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/money_pattern.png'),
                          fit: BoxFit.cover,
                          opacity: 0.1,
                        ),
                      ),
                    ),
                  ),
                ),
                // Hero content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Financial health indicator
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.trending_up_rounded,
                                  color: Colors.greenAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getFinancialHealthStatus(),
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Main story
                      Text(
                        _getMainStoryTitle(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getMainStorySubtitle(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const Spacer(),
                      // Interactive balance display
                      Row(
                        children: [
                          Expanded(
                            child: _buildBalanceIndicator(
                              'Net Flow',
                              _summary?.totalIncome != null
                                ? '\$${((_summary!.totalIncome - _summary!.totalExpenses) / 1000).toStringAsFixed(1)}k'
                                : '\$0',
                              _summary != null && _summary!.totalIncome > _summary!.totalExpenses 
                                ? Colors.greenAccent 
                                : Colors.redAccent,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildBalanceIndicator(
                              'Savings Rate',
                              _summary?.savingsRate != null 
                                ? '${_summary!.savingsRate.toStringAsFixed(1)}%'
                                : '0%',
                              Colors.cyanAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Smart Insights Cards
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < _insights.length) {
                  return _buildSmartInsightCard(_insights[index], index);
                }
                return null;
              },
              childCount: _insights.length.clamp(0, 6), // Max 6 insights
            ),
          ),
        ),
        // Spending Categories with Visual Progress
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppStyle.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.donut_large_rounded,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Where Your Money Flows',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ..._categories.take(5).map((category) => _buildCategoryFlowBar(category)),
              ],
            ),
          ),
        ),
        // Recent Transactions Card
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppStyle.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.push('/transactions');
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: Colors.blue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Recent Transactions',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white.withOpacity(0.5),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        context.push('/transactions/add');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.greenAccent],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildRecentTransactionsList(),
              ],
            ),
          ),
        ),
        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  // Helper methods for revolutionary UI
  String _getFinancialHealthStatus() {
    if (_summary == null) return 'Analyzing...';
    if (_summary!.savingsRate > 20) return 'Excellent';
    if (_summary!.savingsRate > 10) return 'Good';
    if (_summary!.savingsRate > 0) return 'Fair';
    return 'Needs Attention';
  }

  String _getMainStoryTitle() {
    if (_summary == null) return 'Loading your story...';
    
    final netFlow = _summary!.totalIncome - _summary!.totalExpenses;
    if (netFlow > 1000) return 'You\'re Building Wealth! 🚀';
    if (netFlow > 0) return 'Staying Afloat 💪';
    return 'Time to Reassess 🎯';
  }

  String _getMainStorySubtitle() {
    if (_summary == null) return '';
    
    final netFlow = _summary!.totalIncome - _summary!.totalExpenses;
    if (netFlow > 1000) {
      return 'Your financial habits are creating a bright future. Keep it up!';
    } else if (netFlow > 0) {
      return 'You\'re managing well, but there\'s room for improvement.';
    }
    return 'Your expenses are higher than income. Let\'s find opportunities to optimize.';
  }

  Widget _buildBalanceIndicator(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsightCard(InsightItem insight, int index) {
    final colors = [
      [AppStyle.primaryGreen, AppStyle.greenAccent],
      [AppStyle.stateSuccess100, AppStyle.stateSuccess70], 
      [AppStyle.secondaryGlacier100, AppStyle.secondaryGlacier70],
      [AppStyle.primaryLight100, AppStyle.primaryLight70],
      [AppStyle.stateWarning100, AppStyle.stateWarning70],
      [AppStyle.primaryAir100, AppStyle.primaryAir70],
    ];
    
    final cardColors = colors[index % colors.length];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColors[0].withOpacity(0.1),
            cardColors[1].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardColors[0].withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardColors[0].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              insight.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            insight.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              insight.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFlowBar(CategoryData category) {
    final maxAmount = _categories.isNotEmpty 
      ? _categories.map((c) => c.amount).reduce((a, b) => a > b ? a : b)
      : 1.0;
    final percentage = category.amount / maxAmount;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${category.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [category.color, category.color.withOpacity(0.6)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsList() {
    if (_recentTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_outlined,
                color: Colors.white54,
                size: 32,
              ),
              SizedBox(height: 8),
              Text(
                'No recent transactions',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
              Text(
                'Add your first transaction to get started',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _recentTransactions.map((transaction) {
        return GestureDetector(
          onTap: () {
            context.push('/transactions/${transaction.trxId}');
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                // Transaction type indicator
                Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getTransactionColor(transaction),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                // Transaction details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.merchantName ?? transaction.merchantFullText ?? 'Transaction',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(transaction.bookingDate ?? transaction.valueDate ?? DateTime.now()),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${transaction.direction == 'OUT' ? '-' : ''}€${transaction.amount.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          color: _getTransactionColor(transaction),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getTransactionColor(transaction).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          transaction.trxType ?? 'Other',
                          style: TextStyle(
                            color: _getTransactionColor(transaction),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.3),
                  size: 14,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getTransactionColor(Transaction transaction) {
    final direction = transaction.direction;
    if (direction == 'IN') return AppStyle.greenAccent;
    if (direction == 'OUT') return AppStyle.stateError100;
    return Colors.grey;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference} days ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}