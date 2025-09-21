import 'package:flutter/material.dart';
import '../../../core/theme/style.dart';
import '../../../data/services/insights_service.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/services/transaction_api_service.dart';
import '../../../data/local/insights_cache_service.dart';
import '../../../data/models/transaction.dart';
import '../../../shared/widgets/chat_overlay.dart';
import 'widgets/widgets.dart';

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
          floatingActionButton: _buildFloatingActionButton(),
          appBar: _buildAppBar(),
          body: _buildBody(),
        ),
        if (_showChatOverlay) _buildChatOverlay(),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppStyle.darkBackground,
      title: _buildAppBarTitle(),
      actions: [
        _buildRefreshButton(),
        _buildPeriodSelector(),
      ],
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
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
    );
  }

  Widget _buildRefreshButton() {
    return AnimatedContainer(
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
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
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
    );
  }

  Widget _buildBody() {
    return _isLoading ? _buildLoadingIndicator() : _buildRevolutionaryInsightsUI();
  }

  Widget _buildLoadingIndicator() {
    return Center(
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
    );
  }

  Widget _buildChatOverlay() {
    return ChatOverlay(
      onClose: () {
        setState(() {
          _showChatOverlay = false;
        });
      },
    );
  }

  Widget _buildRevolutionaryInsightsUI() {
    return CustomScrollView(
      slivers: [
        // write balance
        SliverToBoxAdapter(
          child: BalanceSummaryWidget(
            summary: _summary,
          ),
        ),

        SliverToBoxAdapter(
          child: InsightsHeaderWidget(
            summary: _summary,
            getFinancialHealthStatus: _getFinancialHealthStatus,
            getMainStoryTitle: _getMainStoryTitle,
            getMainStorySubtitle: _getMainStorySubtitle,
          ),
        ),
        // Smart Insights Cards
        InsightsGridWidget(
          insights: _insights,
          maxInsights: 2,
        ),
        // Spending Categories with Visual Progress
        SliverToBoxAdapter(
          child: CategoryFlowWidget(
            categories: _categories,
            maxCategoriesToShow: 5,
          ),
        ),
        // Recent Transactions Card
        SliverToBoxAdapter(
          child: RecentTransactionsWidget(
            transactions: _recentTransactions,
            maxTransactions: 5,
          ),
        ),
        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  // Helper methods for financial health status and story generation
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
}

