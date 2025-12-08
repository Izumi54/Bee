import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/widgets.dart';

/// Splash Screen - Layar pertama saat app dibuka
/// Menampilkan logo Bee dengan animasi fade in
/// Auto navigate ke Welcome/PIN Login setelah 2 detik
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup fade animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Start animation
    _animationController.forward();

    // Auto navigate setelah 2 detik
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateNext();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Navigate ke screen berikutnya
  /// TODO: Check jika user sudah login, navigate ke PIN Login
  /// Jika belum, navigate ke Welcome Screen
  void _navigateNext() {
    // Untuk sekarang, langsung ke Welcome Screen
    // Nanti akan dicek dari shared preferences
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo dengan animasi
                const BeeLogo(sizeMode: 'large', showText: false),
                const SizedBox(height: 24),

                // Tagline
                Text(
                  'Bee',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'for Everyone',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
