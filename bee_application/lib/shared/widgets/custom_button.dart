import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive_helper.dart';

/// Custom button widget untuk aplikasi Bee
/// Mendukung 2 varian: filled (default) dan outlined
/// Mudah digunakan dengan parameter sederhana
/// RESPONSIVE: width menyesuaikan ukuran screen
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isLoading;
  final double? width;
  final double? height;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Loading state - disable button
    final bool isDisabled = onPressed == null || isLoading;

    if (isOutlined) {
      return _buildOutlinedButton(context, isDisabled);
    } else {
      return _buildFilledButton(context, isDisabled);
    }
  }

  /// Build filled button (default, orange background)
  Widget _buildFilledButton(BuildContext context, bool isDisabled) {
    return SizedBox(
      width: width ?? context.responsive.buttonWidth,
      height: height ?? AppDimensions.buttonHeightMedium,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? AppColors.buttonDisabled
              : AppColors.buttonPrimary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  /// Build outlined button (white background, orange border)
  Widget _buildOutlinedButton(BuildContext context, bool isDisabled) {
    return SizedBox(
      width: width ?? context.responsive.buttonWidth,
      height: height ?? AppDimensions.buttonHeightMedium,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDisabled
              ? AppColors.textDisabled
              : AppColors.primaryOrange,
          side: BorderSide(
            color: isDisabled ? AppColors.borderLight : AppColors.primaryOrange,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  /// Build button content (text, icon, loading indicator)
  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppDimensions.iconMedium),
          SizedBox(width: AppDimensions.spacing8),
          Text(text, style: AppTextStyles.buttonMedium),
        ],
      );
    }

    return Text(
      text,
      style: AppTextStyles.buttonMedium,
      textAlign: TextAlign.center,
    );
  }
}
