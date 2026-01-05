import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/widgets.dart';

/// Pay Later Activation Screen
/// Shows feature info, checks eligibility, activates Pay Later
class PayLaterActivationScreen extends StatefulWidget {
  const PayLaterActivationScreen({super.key});

  @override
  State<PayLaterActivationScreen> createState() =>
      _PayLaterActivationScreenState();
}

class _PayLaterActivationScreenState extends State<PayLaterActivationScreen> {
  bool _isActivating = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final payLaterProvider = context.watch<PayLaterProvider>();

    // Check KYC status
    final isKycVerified = userProvider.currentUser?.isKycVerified ?? false;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Aktifkan Pay Later'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon & Title
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.credit_card,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bee Pay Later',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Belanja sekarang, bayar nanti dengan mudah!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grayMedium1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Benefits
            const Text(
              'Keuntungan Pay Later',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildBenefit(
              Icons.money_off,
              'Cicilan 0%',
              'Tenor 1-3 bulan tanpa bunga',
            ),
            const SizedBox(height: 12),
            _buildBenefit(
              Icons.timeline,
              'Tenor Fleksibel',
              'Pilih cicilan 1, 3, 6, atau 12 bulan',
            ),
            const SizedBox(height: 12),
            _buildBenefit(
              Icons.flash_on,
              'Proses Cepat',
              'Aktivasi hanya butuh beberapa detik',
            ),
            const SizedBox(height: 12),
            _buildBenefit(
              Icons.credit_score,
              'Limit Otomatis',
              'Limit dihitung berdasarkan aktivitas Anda',
            ),
            const SizedBox(height: 32),

            // Requirements
            const Text(
              'Syarat & Ketentuan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRequirement(
              isKycVerified,
              'KYC Terverifikasi',
              isKycVerified ? 'Terverifikasi ✓' : 'Belum Verifikasi',
            ),
            const SizedBox(height: 12),
            _buildRequirement(true, 'Akun Aktif', 'Memenuhi Syarat ✓'),
            const SizedBox(height: 12),
            _buildRequirement(true, 'Tidak Ada Tunggakan', 'Baik ✓'),

            // KYC Warning if not verified
            if (!isKycVerified) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Anda perlu melakukan verifikasi KYC terlebih dahulu untuk mengaktifkan Pay Later.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Activate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isActivating
                    ? null
                    : () => _handleActivate(
                        context,
                        userProvider,
                        payLaterProvider,
                        isKycVerified,
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isActivating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isKycVerified
                            ? 'Aktifkan Pay Later'
                            : 'Lakukan KYC Dulu',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Terms
            Text(
              'Dengan mengaktifkan Pay Later, Anda menyetujui syarat dan ketentuan yang berlaku.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.grayMedium1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C5CE7).withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF6C5CE7), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.grayMedium1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirement(bool isMet, String title, String status) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          color: isMet ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
        Text(
          status,
          style: TextStyle(
            fontSize: 13,
            color: isMet ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _handleActivate(
    BuildContext context,
    UserProvider userProvider,
    PayLaterProvider payLaterProvider,
    bool isKycVerified,
  ) async {
    if (!isKycVerified) {
      // Navigate to KYC
      Navigator.pushNamed(context, '/kyc-selfie');
      return;
    }

    setState(() => _isActivating = true);

    try {
      final userId = userProvider.userId;
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Activate Pay Later
      await payLaterProvider.activate(
        userId: userId,
        userProvider: userProvider,
        transactionCount: 0, // TODO: Get actual transaction count
      );

      if (!mounted) return;

      // Show success and limit
      _showSuccessDialog(context, payLaterProvider.creditLimit);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengaktifkan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isActivating = false);
      }
    }
  }

  void _showSuccessDialog(BuildContext context, double limit) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF6C5CE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selamat!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Pay Later Anda Aktif', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Limit Kredit Anda',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grayMedium1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(limit),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C5CE7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tersedia untuk belanja & transfer',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grayMedium1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Back to home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Mulai Gunakan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
