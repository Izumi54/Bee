import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../shared/widgets/widgets.dart';

/// Setup PIN Screen - Screen setup PIN 6 digit pertama kali
/// User diminta membuat PIN untuk keamanan akun
/// Mudah digunakan: NumPad besar, visual feedback jelas
class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  String _pin = '';
  bool _hasError = false;

  void _onNumberPressed(String number) {
    if (_pin.length < 6) {
      setState(() {
        _pin += number;
        _hasError = false;

        // Auto navigate saat PIN sudah 6 digit
        if (_pin.length == 6) {
          _navigateToConfirm();
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

  void _navigateToConfirm() {
    // Delay sedikit untuk feedback visual
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/confirm-pin',
          arguments: _pin, // Pass PIN untuk konfirmasi
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Buat PIN Keamanan'),
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

              // Icon lock
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 32,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(height: 24),

              // Instruksi
              Text(
                'Buat PIN 6 Digit',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'PIN digunakan untuk masuk ke aplikasi dan mengamankan transaksi Anda',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
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
