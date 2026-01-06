import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/widgets.dart';
import 'package:intl/intl.dart';

/// Transfer Amount Screen - Input jumlah transfer
/// Features: Recipient info, Amount input with formatter, Quick amounts
/// User-friendly: Keyboard angka, format rupiah otomatis
class TransferAmountScreen extends StatefulWidget {
  const TransferAmountScreen({super.key});

  @override
  State<TransferAmountScreen> createState() => _TransferAmountScreenState();
}

class _TransferAmountScreenState extends State<TransferAmountScreen> {
  final TextEditingController _amountController = TextEditingController();
  Map<String, String>? _recipient;
  double _amount = 0;
  String _paymentMethod = 'balance'; // 'balance' or 'pay_later'
  double _userBalance = 0;
  double _payLaterAvailable = 0;
  bool _isPayLaterActive = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get recipient data from arguments
    _recipient =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    // Get user balance and Pay Later info
    final userProvider = context.watch<UserProvider>();
    final payLaterProvider = context.watch<PayLaterProvider>();

    _userBalance = userProvider.balance;
    _isPayLaterActive = payLaterProvider.isActive;
    _payLaterAvailable = payLaterProvider.availableLimit;
  }

  void _onAmountChanged(String value) {
    // Remove non-digits
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanValue.isEmpty) {
      setState(() => _amount = 0);
      _amountController.text = '';
      return;
    }

    final amount = double.parse(cleanValue);
    setState(() => _amount = amount);

    // Format dengan rupiah
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final formatted = formatter.format(amount);
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _setQuickAmount(double amount) {
    _onAmountChanged(amount.toStringAsFixed(0));
  }

  void _continue() {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan jumlah transfer'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    // Check if using Pay Later but not active
    if (_paymentMethod == 'pay_later' && !_isPayLaterActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aktifkan Bee Pay Later terlebih dahulu'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    // Navigate to confirmation
    Navigator.pushNamed(
      context,
      '/transfer-confirmation',
      arguments: {
        'recipient': _recipient,
        'amount': _amount,
        'paymentMethod': _paymentMethod,
      },
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
        title: const Text('Jumlah Transfer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(responsive.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipient Info
              if (_recipient != null) ...[
                Text(
                  'Transfer Ke',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grayLight1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _recipient!['name']![0].toUpperCase(),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _recipient!['name']!,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _recipient!['accountNumber']!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Amount Input
              Text(
                'Jumlah Transfer',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                onChanged: _onAmountChanged,
                keyboardType: TextInputType.number,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryOrange,
                ),
                decoration: InputDecoration(
                  hintText: 'Rp 0',
                  hintStyle: Theme.of(context).textTheme.headlineLarge
                      ?.copyWith(color: AppColors.grayMedium1),
                  filled: true,
                  fillColor: AppColors.grayLight1,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Amount Buttons
              Text(
                'Jumlah Cepat',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickButton('Rp 50.000', 50000),
                  _buildQuickButton('Rp 100.000', 100000),
                  _buildQuickButton('Rp 200.000', 200000),
                  _buildQuickButton('Rp 500.000', 500000),
                  _buildQuickButton('Rp 1.000.000', 1000000),
                ],
              ),
              const SizedBox(height: 32),

              // Payment Method Selection
              _buildPaymentMethodSection(),

              const SizedBox(height: 32),

              // Continue Button
              CustomButton(text: 'Lanjutkan', onPressed: _continue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickButton(String label, double amount) {
    return OutlinedButton(
      onPressed: () => _setQuickAmount(amount),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primaryOrange),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primaryOrange),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final bool isBalanceSufficient = _amount <= _userBalance;
    final double amountNeeded = _amount - _userBalance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metode Pembayaran',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),

        // Balance Option
        _buildPaymentOption(
          method: 'balance',
          title: 'Saldo Bee',
          subtitle: currencyFormat.format(_userBalance),
          icon: Icons.account_balance_wallet,
          isAvailable: isBalanceSufficient,
          warningText: isBalanceSufficient
              ? null
              : 'Saldo tidak cukup (kurang ${currencyFormat.format(amountNeeded)})',
        ),

        const SizedBox(height: 12),

        // Pay Later Option
        if (_isPayLaterActive)
          _buildPaymentOption(
            method: 'pay_later',
            title: 'Bee Pay Later',
            subtitle: 'Tersedia ${currencyFormat.format(_payLaterAvailable)}',
            icon: Icons.credit_card,
            isAvailable: _amount <= _payLaterAvailable,
            warningText: _amount > _payLaterAvailable
                ? 'Limit Pay Later tidak cukup'
                : null,
          ),

        // Activate Pay Later CTA
        if (!_isPayLaterActive && !isBalanceSufficient) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryOrange.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primaryOrange,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Aktifkan Bee Pay Later untuk pinjaman hingga Rp 5.000.000',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/pay-later-activation');
                  },
                  child: const Text('Aktifkan'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentOption({
    required String method,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isAvailable,
    String? warningText,
  }) {
    final isSelected = _paymentMethod == method;

    return GestureDetector(
      onTap: isAvailable
          ? () {
              setState(() {
                _paymentMethod = method;
              });
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange.withOpacity(0.1)
              : AppColors.grayLight1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryOrange
                : isAvailable
                ? AppColors.grayMedium1
                : AppColors.errorRed.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryOrange.withOpacity(0.2)
                        : AppColors.grayMedium1.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? AppColors.primaryOrange
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isAvailable
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryOrange,
                    size: 24,
                  ),
              ],
            ),
            if (warningText != null) ...[
              const SizedBox(height: 8),
              Text(
                warningText,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.errorRed),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
