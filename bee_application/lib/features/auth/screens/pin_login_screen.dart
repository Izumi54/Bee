import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../shared/widgets/widgets.dart';

/// PIN Login Screen - Screen untuk login dengan PIN
/// Shows greeting dengan nama user
/// Input PIN 6 digit untuk masuk
class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String _pin = '';
  bool _hasError = false;
  int _attemptCount = 0;

  // TODO: Get dari SharedPreferences
  final String _userName = 'Rizal';
  final String _savedPin = '123456'; // TODO: Get hashed PIN from storage

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
    // TODO: Compare with hashed PIN from storage
    if (_pin == _savedPin) {
      // PIN benar - login berhasil!
      _showMessage('Login berhasil!', isError: false);

      // Navigate ke Home
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/welcome', // TODO: Navigate to home screen
            (route) => false,
          );
        }
      });
    } else {
      // PIN salah
      setState(() {
        _hasError = true;
        _attemptCount++;
      });

      if (_attemptCount >= 3) {
        _showMessage(
          'Terlalu banyak percobaan. Silakan coba lagi nanti',
          isError: true,
        );
        // TODO: Lock for some time or show forgot PIN option
      } else {
        _showMessage(
          'PIN salah. ${3 - _attemptCount} percobaan lagi',
          isError: true,
        );
      }

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

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.successGreen,
        duration: Duration(milliseconds: isError ? 2000 : 1000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Masuk'),
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
              SizedBox(height: responsive.hp(8)),

              // Logo kecil
              const BeeLogo(sizeMode: 'small', showText: false),
              const SizedBox(height: 32),

              // Greeting
              Text(
                'Haii, $_userName 👋',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Masukkan PIN Anda',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
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

              const SizedBox(height: 16),

              // Forgot PIN link
              TextButton(
                onPressed: () {
                  // TODO: Navigate to forgot PIN flow
                  _showMessage(
                    'Fitur lupa PIN akan segera hadir',
                    isError: false,
                  );
                },
                child: Text(
                  'Lupa PIN?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),

              SizedBox(height: responsive.verticalPadding),
            ],
          ),
        ),
      ),
    );
  }
}
