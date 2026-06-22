import 'package:flutter/material.dart';
import 'package:flutter_with_hive/core/themes.dart';

class GradientPrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final List<Color> colors;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double? width;
  final bool isExpanded;

  const GradientPrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.colors = const [
      AppColors.appBlue,
      AppColors.appPurple,
      AppColors.appPink,
    ],
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 18),
    this.width,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExpanded ? width ?? double.infinity : width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.transparent,
          foregroundColor: AppColors.whiteColor,
          shadowColor: AppColors.transparent,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22),
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
