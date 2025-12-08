import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';

/// NumPad widget untuk input PIN
/// Layout 4x3 dengan angka 0-9, tombol backspace
/// Mudah digunakan dengan ukuran tombol yang besar (72x72px)
class NumPad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback? onBiometricPressed; // Opsional untuk fingerprint

  const NumPad({
    super.key,
    required this.onNumberPressed,
    required this.onBackspacePressed,
    this.onBiometricPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: 1 2 3
        _buildRow(['1', '2', '3']),
        SizedBox(height: AppDimensions.pinButtonSpacing),

        // Row 2: 4 5 6
        _buildRow(['4', '5', '6']),
        SizedBox(height: AppDimensions.pinButtonSpacing),

        // Row 3: 7 8 9
        _buildRow(['7', '8', '9']),
        SizedBox(height: AppDimensions.pinButtonSpacing),

        // Row 4: biometric/empty, 0, backspace
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers
          .map(
            (number) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.pinButtonSpacing / 2,
              ),
              child: _buildNumberButton(number),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left button (biometric atau kosong)
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.pinButtonSpacing / 2,
          ),
          child: onBiometricPressed != null
              ? _buildBiometricButton()
              : _buildEmptyButton(),
        ),

        // Center button (0)
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.pinButtonSpacing / 2,
          ),
          child: _buildNumberButton('0'),
        ),

        // Right button (backspace)
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.pinButtonSpacing / 2,
          ),
          child: _buildBackspaceButton(),
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact(); // Haptic feedback saat tap
          onNumberPressed(number);
        },
        borderRadius: BorderRadius.circular(AppDimensions.pinButtonSize / 2),
        child: Container(
          width: AppDimensions.pinButtonSize,
          height: AppDimensions.pinButtonSize,
          decoration: BoxDecoration(
            color: AppColors.grayLight1,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.grayMedium5, width: 1),
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.numberMedium.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onBackspacePressed();
        },
        borderRadius: BorderRadius.circular(AppDimensions.pinButtonSize / 2),
        child: Container(
          width: AppDimensions.pinButtonSize,
          height: AppDimensions.pinButtonSize,
          decoration: BoxDecoration(
            color: AppColors.grayLight1,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.grayMedium5, width: 1),
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 24,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onBiometricPressed?.call();
        },
        borderRadius: BorderRadius.circular(AppDimensions.pinButtonSize / 2),
        child: Container(
          width: AppDimensions.pinButtonSize,
          height: AppDimensions.pinButtonSize,
          decoration: BoxDecoration(
            color: AppColors.grayLight1,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.grayMedium5, width: 1),
          ),
          child: const Center(
            child: Icon(
              Icons.fingerprint,
              size: 28,
              color: AppColors.primaryOrange,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyButton() {
    return SizedBox(
      width: AppDimensions.pinButtonSize,
      height: AppDimensions.pinButtonSize,
    );
  }
}
