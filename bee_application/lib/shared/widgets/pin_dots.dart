import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Widget untuk menampilkan PIN dots (6 digit)
/// Digunakan di Setup PIN, Confirm PIN, dan PIN Login screens
class PinDots extends StatelessWidget {
  final int length;
  final int filledCount;
  final bool hasError;

  const PinDots({
    super.key,
    this.length = 6,
    required this.filledCount,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (index) => Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.pinDotSpacing / 2,
          ),
          child: _buildDot(index < filledCount),
        ),
      ),
    );
  }

  Widget _buildDot(bool isFilled) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: AppDimensions.pinDotSize,
      height: AppDimensions.pinDotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled
            ? (hasError ? AppColors.errorRed : AppColors.primaryOrange)
            : Colors.transparent,
        border: Border.all(
          color: hasError
              ? AppColors.errorRed
              : (isFilled ? AppColors.primaryOrange : AppColors.grayMedium1),
          width: 2,
        ),
      ),
    );
  }
}
