import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../shared/widgets/widgets.dart';

/// Confirm PIN Screen - Konfirmasi PIN yang baru dibuat
/// User diminta input ulang PIN untuk memastikan tidak salah ketik
/// Validasi otomatis: harus sama dengan PIN pertama
class ConfirmPinScreen extends StatefulWidget {
  const ConfirmPinScreen({super.key});

  @override
  State<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

class _ConfirmPinScreenState extends State<ConfirmPinScreen> {
  String _pin = '';
  String _originalPin = '';
  bool _hasError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get PIN dari previous screen
    _originalPin = ModalRoute.of(context)?.settings.arguments as String? ?? '';
  }

  void _onNumberPressed(String number) {
    if (_pin.length < 6) {
      setState(() {
        _pin += number;
        _hasError = false;

        // Validate saat PIN sudah 6 digit
        if (_pin.length == 6) {
          _validatePin();
        }
      });
    }
  }

  void _onBackspacePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _hasError = false;
      });
    }
  }

  void _validatePin() {
    if (_pin == _originalPin) {
      // PIN match - berhasil!
      _showSuccessAndNavigate();
    } else {
      // PIN tidak match - shake animation & reset
      setState(() => _hasError = true);

      _showMessage('PIN tidak sama, coba lagi', isError: true);

      // Reset setelah delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _pin = '';
            _hasError = false;
          });
        }
      });
    }
  }

  void _showSuccessAndNavigate() {
    // TODO: Save PIN to secure storage (hashed)
    _showMessage('PIN berhasil dibuat!', isError: false);

    // Navigate ke KYC Selfie screen
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushNamed(context, '/kyc-selfie');
      }
    });
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.successGreen,
        duration: Duration(milliseconds: isError ? 2000 : 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Konfirmasi PIN'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.horizontalPadding,
          ),
          child: Column(
            children: [
              SizedBox(height: responsive.hp(6)),

              // Icon check circle
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _hasError
                      ? AppColors.errorRed.withOpacity(0.1)
                      : AppColors.tealCyan.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _hasError ? Icons.error_outline : Icons.check_circle_outline,
                  size: 32,
                  color: _hasError ? AppColors.errorRed : AppColors.tealCyan,
                ),
              ),
              const SizedBox(height: 24),

              // Instruksi
              Text(
                _hasError ? 'PIN Tidak Sama' : 'Konfirmasi PIN Anda',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: _hasError ? AppColors.errorRed : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _hasError
                      ? 'PIN yang Anda masukkan tidak sama. Silakan coba lagi'
                      : 'Masukkan ulang PIN yang baru saja Anda buat',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _hasError
                        ? AppColors.errorRed
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: responsive.hp(6)),

              // PIN Dots
              PinDots(filledCount: _pin.length, hasError: _hasError),

              const Spacer(),

              // NumPad
              NumPad(
                onNumberPressed: _onNumberPressed,
                onBackspacePressed: _onBackspacePressed,
              ),

              SizedBox(height: responsive.verticalPadding),
            ],
          ),
        ),
      ),
    );
  }
}
