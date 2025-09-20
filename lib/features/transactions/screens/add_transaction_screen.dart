import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/services/transaction_api_service.dart';
import '../bloc/add_transaction_bloc.dart';
import '../bloc/add_transaction_event.dart';
import '../bloc/add_transaction_state.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddTransactionBloc(
        transactionRepository: TransactionRepository(
          apiService: TransactionApiService(),
        ),
      )..add(StartAddingTransaction()),
      child: const _AddTransactionView(),
    );
  }
}

class _AddTransactionView extends StatefulWidget {
  const _AddTransactionView();

  @override
  State<_AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<_AddTransactionView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _merchantFocusNode = FocusNode();
  final _amountFocusNode = FocusNode();

  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Listen for merchant text changes to get suggestions
    _merchantController.addListener(() {
      if (_merchantController.text.isNotEmpty) {
        context.read<AddTransactionBloc>().add(
          LoadMerchantSuggestions(_merchantController.text),
        );
      }
    });
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _merchantFocusNode.dispose();
    _amountFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: 'Manual'),
            Tab(icon: Icon(Icons.mic), text: 'Voice'),
            Tab(icon: Icon(Icons.camera_alt), text: 'Camera'),
            Tab(icon: Icon(Icons.receipt), text: 'Receipt'),
          ],
          onTap: (index) {
            final inputMethod = TransactionInputMethod.values[index];
            context.read<AddTransactionBloc>().add(
              SetTransactionInputMethod(inputMethod),
            );
          },
        ),
      ),
      body: BlocListener<AddTransactionBloc, AddTransactionState>(
        listener: (context, state) {
          if (state is AddTransactionSuccess) {
            _showSuccessDialog(context, state.transaction);
          } else if (state is AddTransactionError) {
            _showErrorSnackBar(context, state.message);
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildManualEntryTab(),
            _buildVoiceInputTab(),
            _buildCameraTab(),
            _buildReceiptTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEntryTab() {
    return BlocBuilder<AddTransactionBloc, AddTransactionState>(
      builder: (context, state) {
        final isLoading = state is AddTransactionSubmitting;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputMethodCard(),
                const SizedBox(height: 16),
                _buildMerchantField(state),
                const SizedBox(height: 16),
                _buildAmountField(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 16),
                _buildDateField(),
                const SizedBox(height: 16),
                _buildTransactionTypeField(),
                const SizedBox(height: 24),
                if (state is AddTransactionFormInProgress && state.validationErrors.isNotEmpty)
                  _buildValidationErrors(state.validationErrors),
                _buildSubmitButton(isLoading),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputMethodCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Add Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.mic,
                    label: 'Voice',
                    onTap: () => _tabController.animateTo(1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => _tabController.animateTo(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.receipt,
                    label: 'Receipt',
                    onTap: () => _tabController.animateTo(3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryGreen),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantField(AddTransactionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _merchantController,
          focusNode: _merchantFocusNode,
          decoration: InputDecoration(
            labelText: 'Merchant / Payee',
            hintText: 'Enter merchant name',
            prefixIcon: const Icon(Icons.store),
            border: const OutlineInputBorder(),
            suffixIcon: _merchantController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _merchantController.clear();
                      context.read<AddTransactionBloc>().updateField(merchantName: '');
                    },
                  )
                : null,
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a merchant name';
            }
            return null;
          },
          onChanged: (value) {
            context.read<AddTransactionBloc>().updateField(merchantName: value);
          },
        ),
        if (state is AddTransactionFormInProgress && state.merchantSuggestions.isNotEmpty)
          _buildMerchantSuggestions(state.merchantSuggestions),
      ],
    );
  }

  Widget _buildMerchantSuggestions(List<String> suggestions) {
    return Card(
      margin: const EdgeInsets.only(top: 4),
      child: Column(
        children: suggestions.take(3).map((suggestion) {
          return ListTile(
            dense: true,
            leading: const Icon(Icons.history, size: 16),
            title: Text(suggestion),
            onTap: () {
              _merchantController.text = suggestion;
              context.read<AddTransactionBloc>().add(
                SelectMerchantSuggestion(merchantName: suggestion),
              );
              _merchantFocusNode.unfocus();
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      focusNode: _amountFocusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: const InputDecoration(
        labelText: 'Amount',
        hintText: '0.00',
        prefixText: 'CHF ',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Please enter an amount';
        }
        final amount = double.tryParse(value!);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount greater than 0';
        }
        return null;
      },
      onChanged: (value) {
        final amount = double.tryParse(value);
        context.read<AddTransactionBloc>().updateField(amount: amount);
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Additional notes about this transaction',
        prefixIcon: Icon(Icons.description),
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
      onChanged: (value) {
        context.read<AddTransactionBloc>().updateField(description: value);
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
          context.read<AddTransactionBloc>().updateField(date: date);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Transaction Date',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Transaction Type',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'PAYMENT', child: Text('Payment')),
        DropdownMenuItem(value: 'CARD_PAYMENT', child: Text('Card Payment')),
        DropdownMenuItem(value: 'TRANSFER', child: Text('Transfer')),
        DropdownMenuItem(value: 'WITHDRAWAL', child: Text('Withdrawal')),
        DropdownMenuItem(value: 'DEPOSIT', child: Text('Deposit')),
      ],
      value: 'PAYMENT',
      onChanged: (value) {
        if (value != null) {
          context.read<AddTransactionBloc>().updateField(trxType: value);
        }
      },
    );
  }

  Widget _buildValidationErrors(List<String> errors) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'Please fix the following:',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...errors.map((error) => Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 4),
              child: Text(
                '• $error',
                style: TextStyle(color: Colors.red.shade700),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : () {
        if (_formKey.currentState?.validate() ?? false) {
          context.read<AddTransactionBloc>().submit();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isLoading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Adding Transaction...'),
              ],
            )
          : const Text(
              'Add Transaction',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildVoiceInputTab() {
    return BlocBuilder<AddTransactionBloc, AddTransactionState>(
      builder: (context, state) {
        final isProcessing = state is AddTransactionProcessingVoice;
        
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mic,
                size: 80,
                color: isProcessing ? AppTheme.primaryGreen : Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                isProcessing 
                    ? 'Processing your voice input...'
                    : 'Tap to record your transaction',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Say something like: "I spent 25 francs at Starbucks for coffee"',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: isProcessing ? null : () {
                  // TODO: Implement actual voice recording
                  context.read<AddTransactionBloc>().add(
                    const AddTransactionFromVoice(audioPath: 'mock_audio_path'),
                  );
                },
                icon: isProcessing 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.mic),
                label: Text(isProcessing ? 'Processing...' : 'Start Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(
            'Take a photo to create transaction',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Point your camera at a receipt, menu, or any item you want to track',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement camera functionality
              _showComingSoonDialog('Camera feature');
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(
            'Scan your receipt',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Take a clear photo of your receipt and we\'ll extract the transaction details automatically',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement camera functionality
                  _showComingSoonDialog('Receipt camera feature');
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement gallery functionality
                  _showComingSoonDialog('Gallery selection feature');
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Colors.green.shade600,
          size: 48,
        ),
        title: const Text('Transaction Added!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your transaction has been successfully recorded.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    transaction.formattedAmount,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(transaction.displayDescription),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.read<AddTransactionBloc>().reset();
            },
            child: const Text('Add Another'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Navigate back to transactions screen using go_router
              context.go('/transactions');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon!'),
        content: Text('$feature will be available in a future update.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}