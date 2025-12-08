import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';

/// Widget logo Bee placeholder
/// Akan diganti dengan logo asli nanti
/// RESPONSIVE: size menyesuaikan screen size
class BeeLogo extends StatelessWidget {
  final double? size;
  final bool showText;
  final String sizeMode; // 'small', 'medium', 'large', 'custom'

  const BeeLogo({
    super.key,
    this.size,
    this.showText = true,
    this.sizeMode = 'medium', // default medium
  });

  @override
  Widget build(BuildContext context) {
    // Get responsive size
    final double logoSize = _getLogoSize(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo placeholder (bee icon)
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.savings, // Temporary icon
            size: logoSize * 0.5,
            color: AppColors.primaryOrange,
          ),
        ),

        if (showText) ...[
          SizedBox(height: logoSize * 0.2),
          // Logo text
          Text(
            'Bee',
            style: TextStyle(
              fontSize: logoSize * 0.3,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryOrange,
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }

  /// Get logo size based on size mode or custom size
  double _getLogoSize(BuildContext context) {
    // If custom size provided, use it
    if (size != null) {
      return size!;
    }

    // Otherwise use responsive size based on mode
    final responsive = context.responsive;
    switch (sizeMode) {
      case 'small':
        return responsive.logoSizeSmall;
      case 'large':
        return responsive.logoSizeLarge;
      case 'medium':
      default:
        return responsive.logoSizeMedium;
    }
  }
}
