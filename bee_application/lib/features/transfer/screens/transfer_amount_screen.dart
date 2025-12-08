import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get recipient data from arguments
    _recipient =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
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

    // Navigate to confirmation
    Navigator.pushNamed(
      context,
      '/transfer-confirmation',
      arguments: {'recipient': _recipient, 'amount': _amount},
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

              // Balance Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.tealCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.tealCyan.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.tealCyan,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Saldo Anda: Rp 2.500.000',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
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
}
