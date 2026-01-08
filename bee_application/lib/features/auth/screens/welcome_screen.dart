import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../shared/widgets/widgets.dart';

/// Welcome Screen - Layar onboarding dengan pilihan Masuk/Daftar
/// Design: Logo di atas, 2 button besar di bawah
/// User-friendly: Button besar, spacing comfortable
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.horizontalPadding,
            vertical: responsive.verticalPadding,
          ),
          child: Column(
            children: [
              // Logo dinaikkan
              SizedBox(height: responsive.hp(4)),

              // Logo besar
              const BeeLogo(sizeMode: 'large', showText: true),

              const SizedBox(height: 24),

              // Tagline
              Text(
                'Smart Finance for Everyone',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Tagline utama
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Kelola keuangan Anda dengan mudah dan aman',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Button Daftar (Primary)
              CustomButton(
                text: 'Daftar',
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),

              const SizedBox(height: 16),

              // Button Masuk (Outlined)
              CustomButton(
                text: 'Masuk',
                onPressed: () {
                  Navigator.pushNamed(context, '/pin-login');
                },
                isOutlined: true,
              ),

              SizedBox(height: responsive.verticalPadding),
            ],
          ),
        ),
      ),
    );
  }
}
