import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/widgets.dart';

/// Top Up Screen - Tambah saldo ke akun
/// Features: Amount selection, Custom amount, Payment method
class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final TextEditingController _amountController = TextEditingController();
  int _selectedAmount = 0;
  bool _isProcessing = false;

  final List<int> _quickAmounts = [
    50000,
    100000,
    200000,
    500000,
    1000000,
    2000000,
  ];

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  int get _amount {
    if (_selectedAmount > 0) return _selectedAmount;
    final text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(text) ?? 0;
  }

  Future<void> _processTopUp() async {
    final amount = _amount;
    if (amount < 10000) {
      _showMessage('Minimal top up Rp 10.000', isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Add balance
      final userProvider = context.read<UserProvider>();
      final success = await userProvider.addBalance(amount.toDouble());

      if (!success) {
        throw Exception('Gagal menambah saldo');
      }

      // Add transaction record
      final transactionProvider = context.read<TransactionProvider>();
      await transactionProvider.addTopUp(amount: amount.toDouble());

      // Simulate processing delay
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _isProcessing = false);

      if (mounted) {
        _showSuccessDialog(amount);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showMessage('Top up gagal: ${e.toString()}', isError: true);
    }
  }

  void _showSuccessDialog(int amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 40,
                color: AppColors.successGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Top Up Berhasil!',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(amount),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.successGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Saldo Anda berhasil ditambahkan',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Back to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
              ),
              child: const Text('Kembali ke Beranda'),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.successGreen,
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Top Up Saldo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(responsive.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Balance
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: AppColors.primaryOrange,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Saldo saat ini',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  Text(
                                    currencyFormat.format(userProvider.balance),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryOrange,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Quick Amount Selection
                    Text(
                      'Pilih Nominal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.0,
                          ),
                      itemCount: _quickAmounts.length,
                      itemBuilder: (context, index) {
                        final amount = _quickAmounts[index];
                        final isSelected = _selectedAmount == amount;

                        return Material(
                          color: isSelected
                              ? AppColors.primaryOrange
                              : AppColors.grayLight1,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedAmount = amount;
                                _amountController.clear();
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Text(
                                currencyFormat.format(amount),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.textPrimary,
                                    ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Custom Amount
                    Text(
                      'Atau masukkan nominal lain',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          _selectedAmount = 0;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Minimal Rp 10.000',
                        prefixText: 'Rp ',
                        filled: true,
                        fillColor: AppColors.grayLight1,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment Method (Simulated)
                    Text(
                      'Metode Pembayaran',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentMethod(
                      icon: Icons.account_balance,
                      title: 'Transfer Bank',
                      subtitle: 'Virtual Account',
                      isSelected: true,
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentMethod(
                      icon: Icons.store,
                      title: 'Minimarket',
                      subtitle: 'Alfamart, Indomaret',
                      isSelected: false,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Container(
              padding: EdgeInsets.all(responsive.horizontalPadding),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_amount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Top Up',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            currencyFormat.format(_amount),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryOrange,
                                ),
                          ),
                        ],
                      ),
                    ),
                  CustomButton(
                    text: 'Top Up Sekarang',
                    onPressed: (_amount < 10000 || _isProcessing)
                        ? null
                        : _processTopUp,
                    isLoading: _isProcessing,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryOrange.withValues(alpha: 0.1)
            : AppColors.grayLight1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryOrange : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryOrange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: AppColors.primaryOrange),
        ],
      ),
    );
  }
}
