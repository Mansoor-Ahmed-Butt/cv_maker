import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/widgets/text/app_style.dart';

class AppGradientScaffold extends StatelessWidget {
  const AppGradientScaffold({
    super.key,
    required this.child,
    this.padding,
    this.safeArea = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: const BoxDecoration(
        gradient: AppColors.homeBackgroundGradient,
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: AppColors.homeBackgroundColor1,
      body: content,
    );
  }
}

class AppGlassCard extends StatelessWidget {
  const AppGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceDark.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: Border.all(
          color: borderColor ?? AppColors.whiteColor.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppStyle.style24w700(color: AppColors.whiteColor)),
        if (action != null) action!,
      ],
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppGlassCard(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryAccentGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.whiteColor, size: 28.r),
              ),
              SizedBox(height: 18.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppStyle.style20w700(color: AppColors.whiteColor),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppStyle.style14w400(
                  color: AppColors.whiteColor.withValues(alpha: 0.72),
                ),
              ),
              if (action != null) ...[SizedBox(height: 20.h), action!],
            ],
          ),
        ),
      ),
    );
  }
}
