import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/providers/user_provider.dart';
import '../../../shared/widgets/widgets.dart';

/// PIN Login Screen - Screen untuk login dengan PIN
/// Shows greeting dengan nama user dari storage
/// Input PIN 6 digit untuk masuk dengan validasi hash
class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String _pin = '';
  bool _hasError = false;
  int _attemptCount = 0;
  bool _isLocked = false;

  void _onNumberPressed(String number) {
    if (_isLocked) return;

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
    if (_isLocked) return;

    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _hasError = false;
      });
    }
  }

  void _validatePin() {
    final userProvider = context.read<UserProvider>();

    // Hash the input PIN
    final bytes = utf8.encode(_pin);
    final hashedInput = sha256.convert(bytes).toString();

    // Compare with stored hashed PIN
    if (userProvider.verifyPin(hashedInput)) {
      // PIN benar - login berhasil!
      userProvider.login();
      _showMessage('Login berhasil!', isError: false);

      // Navigate ke Home
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      });
    } else {
      // PIN salah
      setState(() {
        _hasError = true;
        _attemptCount++;
      });

      if (_attemptCount >= 3) {
        setState(() => _isLocked = true);
        _showMessage(
          'Terlalu banyak percobaan. Coba lagi dalam 30 detik',
          isError: true,
        );

        // Unlock after 30 seconds
        Future.delayed(const Duration(seconds: 30), () {
          if (mounted) {
            setState(() {
              _isLocked = false;
              _attemptCount = 0;
              _pin = '';
            });
            _showMessage('Anda dapat mencoba lagi', isError: false);
          }
        });
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
    final userProvider = context.watch<UserProvider>();
    final userName =
        userProvider.currentUser?.fullName.split(' ').first ?? 'User';

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
                'Haii, $userName 👋',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _isLocked ? 'Akun terkunci sementara' : 'Masukkan PIN Anda',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _isLocked
                      ? AppColors.errorRed
                      : AppColors.textSecondary,
                ),
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
                onPressed: _isLocked
                    ? null
                    : () {
                        _showMessage(
                          'Fitur lupa PIN akan segera hadir',
                          isError: false,
                        );
                      },
                child: Text(
                  'Lupa PIN?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _isLocked
                        ? AppColors.textSecondary
                        : AppColors.primaryOrange,
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
