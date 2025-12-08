import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../shared/widgets/widgets.dart';

/// Transaction Detail Screen - Detail transaksi dari history
/// Shows: Type, Amount, Recipient, Date, Status
class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm:ss', 'id_ID');

    // Get transaction from arguments
    final transaction =
        ModalRoute.of(context)?.settings.arguments as Transaction?;

    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Transaksi')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    final isIncoming = transaction.isIncoming;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
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
                  children: [
                    const SizedBox(height: 24),

                    // Status Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 48,
                        color: AppColors.successGreen,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status Text
                    Text(
                      'Transaksi Berhasil',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.successGreen,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Transaction Type
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isIncoming
                            ? AppColors.successGreen.withValues(alpha: 0.1)
                            : AppColors.primaryOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getTransactionTypeName(transaction.type),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isIncoming
                              ? AppColors.successGreen
                              : AppColors.primaryOrange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Amount
                    Text(
                      '${isIncoming ? '+' : '-'} ${currencyFormat.format(transaction.amount)}',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isIncoming
                                ? AppColors.successGreen
                                : AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 32),

                    // Detail Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.grayLight1,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            context,
                            'ID Transaksi',
                            '#${transaction.id.substring(0, 8).toUpperCase()}',
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            context,
                            'Deskripsi',
                            transaction.description,
                          ),
                          if (transaction.recipientName != null) ...[
                            const Divider(height: 24),
                            _buildDetailRow(
                              context,
                              'Penerima',
                              transaction.recipientName!,
                            ),
                          ],
                          if (transaction.recipientAccount != null) ...[
                            const Divider(height: 24),
                            _buildDetailRow(
                              context,
                              'No. Rekening',
                              transaction.recipientAccount!,
                            ),
                          ],
                          const Divider(height: 24),
                          _buildDetailRow(
                            context,
                            'Tanggal',
                            dateFormat.format(transaction.createdAt),
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            context,
                            'Waktu',
                            timeFormat.format(transaction.createdAt),
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            context,
                            'Status',
                            'Berhasil',
                            valueColor: AppColors.successGreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: EdgeInsets.all(responsive.horizontalPadding),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Bagikan',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur bagikan akan segera hadir'),
                          ),
                        );
                      },
                      isOutlined: true,
                      icon: Icons.share,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Kembali',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _getTransactionTypeName(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return 'Transfer Keluar';
      case TransactionType.receive:
        return 'Transfer Masuk';
      case TransactionType.topUp:
        return 'Top Up';
      case TransactionType.payment:
        return 'Pembayaran';
    }
  }
}
