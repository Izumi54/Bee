import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../shared/widgets/widgets.dart';
import 'package:intl/intl.dart';

/// Transfer Confirmation Screen - Review & confirm transfer
/// Features: Transaction details, Optional note, PIN confirmation
/// User-friendly: Clear breakdown, confirm action
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get transfer data from arguments
    _transferData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  Future<void> _confirmTransfer() async {
    setState(() => _isProcessing = true);

    // Simulate transfer processing
    await Future.delayed(const Duration(seconds: 2));

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
                              color: AppColors.primaryOrange.withOpacity(0.1),
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

                    // Transaction Details
                    _buildDetailCard(context, [
                      _DetailRow('Penerima', recipient['name']!),
                      _DetailRow('Nomor Rekening', recipient['accountNumber']!),
                      _DetailRow(
                        'Jumlah Transfer',
                        currencyFormat.format(amount),
                      ),
                      _DetailRow('Biaya Admin', 'GRATIS'),
                      Divider(),
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: CustomButton(
                text: 'Konfirmasi Transfer',
                onPressed: _isProcessing ? null : _confirmTransfer,
                isLoading: _isProcessing,
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
