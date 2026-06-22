import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/widgets/common/app_shell.dart';
import 'package:flutter_with_hive/widgets/text/app_style.dart';

class AppAuthLayout extends StatelessWidget {
  const AppAuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 700;

    return AppGradientScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isCompact ? double.infinity : 520.w,
            ),
            child: AppGlassCard(
              borderRadius: 32,
              backgroundColor: AppColors.surfaceDark.withValues(alpha: 0.86),
              padding: EdgeInsets.all(28.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryAccentGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      color: AppColors.whiteColor,
                      size: 30.r,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    title,
                    style: AppStyle.style30w700(color: AppColors.whiteColor),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    style: AppStyle.style14w400(
                      color: AppColors.whiteColor.withValues(alpha: 0.72),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  form,
                  if (footer != null) ...[SizedBox(height: 20.h), footer!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
