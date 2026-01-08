import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/widgets.dart';

/// Transfer Confirmation Screen - Review & confirm transfer
/// Features: Balance check, Deduct balance, Save transaction, PIN confirmation
class TransferConfirmationScreen extends StatefulWidget {
  const TransferConfirmationScreen({super.key});

  @override
  State<TransferConfirmationScreen> createState() =>
      _TransferConfirmationScreenState();
}

class _TransferConfirmationScreenState
    extends State<TransferConfirmationScreen> {
  final TextEditingController _noteController = TextEditingController();
  Map<String, dynamic>? _transferData;
  bool _isProcessing = false;
  int _selectedTenor = 3; // Default 3 months for Pay Later

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _transferData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  Future<void> _confirmTransfer() async {
    if (_transferData == null) return;

    final recipient = _transferData!['recipient'] as Map<String, String>;
    final amount = _transferData!['amount'] as double;
    final paymentMethod =
        _transferData!['paymentMethod'] as String? ?? 'balance';

    // Get providers
    final userProvider = context.read<UserProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final payLaterProvider = context.read<PayLaterProvider>();

    // Debug: Log payment method
    debugPrint('🔍 Payment Method: $paymentMethod');

    // Check payment method requirements
    if (paymentMethod == 'balance') {
      if (userProvider.balance < amount) {
        _showMessage('Saldo tidak mencukupi', isError: true);
        return;
      }
    } else if (paymentMethod == 'pay_later') {
      if (!payLaterProvider.isActive) {
        _showMessage('Pay Later belum aktif', isError: true);
        return;
      }
      if (payLaterProvider.availableLimit < amount) {
        _showMessage('Limit Pay Later tidak cukup', isError: true);
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      if (paymentMethod == 'balance') {
        // Balance payment
        final balanceSuccess = await userProvider.deductBalance(amount);
        if (!balanceSuccess) {
          throw Exception('Gagal memproses saldo');
        }

        await transactionProvider.addTransfer(
          amount: amount,
          recipientName: recipient['name']!,
          recipientAccount: recipient['accountNumber']!,
        );
      } else if (paymentMethod == 'pay_later') {
        // Pay Later payment
        final userId = userProvider.userId;

        if (userId == null) {
          throw Exception('User tidak terautentikasi');
        }

        await payLaterProvider.createLoan(
          userId: userId,
          amount: amount,
          tenorMonths: _selectedTenor,
          purpose: 'transfer',
          recipientName: recipient['name'],
        );

        await transactionProvider.addTransfer(
          amount: amount,
          recipientName: recipient['name']!,
          recipientAccount: recipient['accountNumber']!,
        );
      }

      // 3. Small delay for UX
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _isProcessing = false);

      if (mounted) {
        // Navigate to success screen
        Navigator.pushNamed(
          context,
          '/transaction-success',
          arguments: {
            ..._transferData!,
            'note': _noteController.text,
            'timestamp': DateTime.now(),
          },
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showMessage('Transfer gagal: ${e.toString()}', isError: true);
    }
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
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (_transferData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Konfirmasi Transfer')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    final recipient = _transferData!['recipient'] as Map<String, String>;
    final amount = _transferData!['amount'] as double;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Konfirmasi Transfer'),
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
                    // Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              size: 32,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Konfirmasi Transfer',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pastikan data sudah benar',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Balance info dihapus untuk simplifikasi
                    // Transfer tetap berfungsi tanpa info saldo
                    const SizedBox(height: 8),
                    const SizedBox(height: 24),

                    // Transaction Details
                    _buildDetailCard(context, [
                      _DetailRow('Penerima', recipient['name']!),
                      _DetailRow('Nomor Rekening', recipient['accountNumber']!),
                      _DetailRow(
                        'Jumlah Transfer',
                        currencyFormat.format(amount),
                      ),
                      _DetailRow('Biaya Admin', 'GRATIS'),
                      const Divider(),
                      _DetailRow(
                        'Total',
                        currencyFormat.format(amount),
                        isTotal: true,
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Note (Optional)
                    Text(
                      'Catatan (Opsional)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      maxLength: 100,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan untuk transfer ini',
                        filled: true,
                        fillColor: AppColors.grayLight1,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
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
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final isInsufficient = userProvider.balance < amount;

                  return CustomButton(
                    text: isInsufficient
                        ? 'Saldo Tidak Cukup'
                        : 'Konfirmasi Transfer',
                    onPressed: (_isProcessing || isInsufficient)
                        ? null
                        : _confirmTransfer,
                    isLoading: _isProcessing,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grayLight1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children.map((child) {
          if (child is Divider) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: child,
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: child,
          );
        }).toList(),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _DetailRow(this.label, this.value, {this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isTotal ? AppColors.primaryOrange : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
