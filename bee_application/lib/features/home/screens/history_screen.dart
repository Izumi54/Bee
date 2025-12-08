import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/providers/transaction_provider.dart';

/// History Screen - Riwayat transaksi dari TransactionProvider
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          if (transactionProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            );
          }

          final transactions = transactionProvider.transactions;

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: AppColors.grayMedium1,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada transaksi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Transaksi Anda akan muncul di sini',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(responsive.horizontalPadding),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final isIncoming = transaction.isIncoming;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isIncoming
                            ? AppColors.successGreen.withValues(alpha: 0.1)
                            : AppColors.primaryOrange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getTransactionIcon(transaction.type),
                        color: isIncoming
                            ? AppColors.successGreen
                            : AppColors.primaryOrange,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Description & Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.description,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(transaction.createdAt),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),

                    // Amount
                    Text(
                      '${isIncoming ? '+' : '-'} ${currencyFormat.format(transaction.amount)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isIncoming
                            ? AppColors.successGreen
                            : AppColors.errorRed,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return Icons.arrow_upward;
      case TransactionType.receive:
        return Icons.arrow_downward;
      case TransactionType.topUp:
        return Icons.add_circle_outline;
      case TransactionType.payment:
        return Icons.payment;
    }
  }
}
