import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/widgets.dart';

/// Email Verification Screen
/// User harus verify email sebelum lanjut ke setup PIN
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _isResending = false;
  Timer? _checkTimer;
  int _resendCountdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Auto-check verification status every 3 seconds
    _startAutoCheck();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Auto-check email verification status
  void _startAutoCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerified();
    });
  }

  /// Check if email is verified
  Future<void> _checkEmailVerified() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    try {
      final userProvider = context.read<UserProvider>();
      final isVerified = await userProvider.checkEmailVerified();

      if (isVerified && mounted) {
        _checkTimer?.cancel();
        // Navigate to Setup PIN
        Navigator.pushReplacementNamed(context, '/setup-pin');
      }
    } catch (e) {
      // Silently fail, will retry in 3 seconds
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  /// Resend verification email
  Future<void> _resendEmail() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.sendEmailVerification();

      if (mounted) {
        _showMessage('Email verifikasi telah dikirim ulang!', isError: false);

        // Start 60 second countdown
        setState(() => _resendCountdown = 60);
        _countdownTimer?.cancel();
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (_resendCountdown > 0) {
              _resendCountdown--;
            } else {
              timer.cancel();
            }
          });
        });
      }
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  /// Logout and go back to welcome
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Registrasi?'),
        content: const Text(
          'Akun Anda akan dihapus. Anda harus registrasi ulang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final userProvider = context.read<UserProvider>();
        await userProvider.logout();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/welcome',
            (route) => false,
          );
        }
      } catch (e) {
        _showMessage('Gagal logout', isError: true);
      }
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
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final userProvider = context.watch<UserProvider>();
    final email = userProvider.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Verifikasi Email'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Batalkan',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(responsive.horizontalPadding),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Email Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 60,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Cek Email Anda',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Kami telah mengirim link verifikasi ke:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Email
              Text(
                email,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryOrange,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Instructions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.grayLight1,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInstruction('1', 'Buka inbox email Anda'),
                    const SizedBox(height: 12),
                    _buildInstruction('2', 'Cari email dari Bee E-Wallet'),
                    const SizedBox(height: 12),
                    _buildInstruction('3', 'Klik link verifikasi di email'),
                    const SizedBox(height: 12),
                    _buildInstruction('4', 'Kembali ke app ini'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Auto-checking indicator
              if (_isChecking)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Mengecek verifikasi...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Resend button
              CustomButton(
                text: _resendCountdown > 0
                    ? 'Kirim Ulang ($_resendCountdown)'
                    : 'Kirim Ulang Email',
                onPressed: _resendCountdown > 0 || _isResending
                    ? null
                    : _resendEmail,
                isLoading: _isResending,
                isOutlined: true,
              ),
              const SizedBox(height: 16),

              // Info
              Text(
                'Tidak menerima email? Cek folder spam atau klik "Kirim Ulang"',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction(String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.primaryOrange,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
