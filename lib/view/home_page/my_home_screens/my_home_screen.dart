import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/widgets/common/app_shell.dart';
import 'package:flutter_with_hive/widgets/custom_icon_button.dart';
import 'package:flutter_with_hive/widgets/create_resume_alert/resume_dialog.dart';
import 'package:flutter_with_hive/widgets/text/app_style.dart';

// Animated Home Screen

class AnimatedHomeScreen extends StatefulWidget {
  const AnimatedHomeScreen({super.key});

  @override
  State<AnimatedHomeScreen> createState() => _AnimatedHomeScreenState();
}

class _AnimatedHomeScreenState extends State<AnimatedHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.homeBackgroundColor1,
            AppColors.homeBackgroundColor2,
            AppColors.homeBackgroundColor3,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated Background Circles
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Positioned(
                top: -100,
                right: -100,
                child: Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.bgAnimatedCircleColor1.withValues(
                            alpha: 0.15,
                          ),
                          AppColors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              //padding: const EdgeInsets.only(bottom: 120),
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [AppColors.appBlue, AppColors.appPink],
                              ).createShader(bounds),
                              child: Text(
                                'Hello, Creative! ✨',
                                style: AppStyle.style18w500(
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Build Your Future',
                              style: AppStyle.style32w700(
                                color: AppColors.whiteColor,
                              ).copyWith(letterSpacing: -0.5),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.all(14.r),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.appBlue.withValues(alpha: 0.3),
                                    AppColors.appPink.withValues(alpha: 0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(
                                  color: AppColors.whiteColor.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: CustomIcon(
                                iconOnly: true,
                                icon: Icons.notifications_rounded,
                                iconColor: AppColors.whiteColor,
                                size: 26.r,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 10.w,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  color: AppColors.appPink,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.appPink.withValues(
                                        alpha: 0.6,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // Floating Hero Card with Animation
                    AnimatedBuilder(
                      animation: _floatingController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            10 * math.sin(_floatingController.value * math.pi),
                          ),
                          child: child,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(28.r),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.appBlue,
                              AppColors.appPurple,
                              AppColors.appPink,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.appBlue.withValues(alpha: 0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor.withValues(
                                      alpha: 0.25,
                                    ),
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.blackColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: CustomIcon(
                                    iconOnly: true,
                                    icon: Icons.workspace_premium_rounded,
                                    iconColor: AppColors.whiteColor,
                                    size: 36.r,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.blackColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    children: [
                                      CustomIcon(
                                        iconOnly: true,
                                        icon: Icons.star_rounded,
                                        iconColor: AppColors.appYellowC,
                                        size: 18.r,
                                      ),

                                      SizedBox(width: 4.w),
                                      Text(
                                        'Premium',
                                        style: AppStyle.style13w600(
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              'Create Your\nDream Resume',
                              style: AppStyle.style28w700(
                                color: AppColors.whiteColor,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'AI-powered templates designed by experts to help you land your dream job faster',
                              style: AppStyle.style15w500(
                                color: AppColors.whiteColor.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.blackColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: AppColors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16.r),
                                  onTap: () {},
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 18.h,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ShaderMask(
                                          shaderCallback: (bounds) =>
                                              const LinearGradient(
                                                colors: [
                                                  AppColors.appBlue,
                                                  AppColors.appPink,
                                                ],
                                              ).createShader(bounds),
                                          child: Text(
                                            'Start Creating Now',
                                            style: AppStyle.style17w700(
                                              color: AppColors.whiteColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),

                                        CustomIcon(
                                          iconOnly: true,
                                          icon: Icons.arrow_forward_rounded,
                                          iconColor: AppColors.appBlue,
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '2.5K+',
                            'Templates',
                            Icons.description_rounded,
                            AppColors.appGreenC,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            '500K+',
                            'Users',
                            Icons.people_rounded,
                            AppColors.appBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            '98%',
                            'Success',
                            Icons.trending_up_rounded,
                            AppColors.appPink,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // Features Grid
                    const AppSectionHeader(title: 'Powerful Features'),
                    SizedBox(height: 16.h),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.95,
                      children: [
                        InkWell(
                          // onTap: () {
                          //   showDialog(
                          //     context: context,
                          //     barrierDismissible: false,
                          //     barrierColor: Colors.transparent.withValues(alpha: 0.5),
                          //     builder: (BuildContext context) {
                          //       return const PremiumResumeDialog();
                          //     },
                          //   ).then((data) {
                          //     if (data != null) {
                          //       printLog('Resume Data: $data');
                          //       // Handle the resume creation with the data
                          //     }
                          //   });
                          // },
                          // onTap: () {
                          //   showCustomDialog(
                          //     context: context,
                          //     title: 'Delete Resume?',
                          //     description: 'Are you sure you want to delete this resume? This action cannot be undone.',
                          //     icon: Icons.warning_rounded,
                          //     onConfirm: () {
                          //       print('Resume deleted!');
                          //     },
                          //     onCancel: () {
                          //       print('Cancelled');
                          //     },
                          //   );
                          // },
                          onTap: () {
                            // Replace your old alertForResume call with:
                            showPremiumResumeDialog(context);
                            // alertForResume(context);
                          },

                          child: _buildFeatureCard(
                            'AI Writer',
                            'Smart content generation',
                            Icons.auto_awesome_rounded,
                            LinearGradient(
                              colors: [AppColors.appBlue, AppColors.appPurple],
                            ),
                          ),
                        ),
                        _buildFeatureCard(
                          'Export PDF',
                          'Professional documents',
                          Icons.picture_as_pdf_rounded,
                          const LinearGradient(
                            colors: [AppColors.appPink, AppColors.appOrangeC],
                          ),
                        ),
                        _buildFeatureCard(
                          'Templates',
                          '100+ designs available',
                          Icons.palette_rounded,
                          const LinearGradient(
                            colors: [
                              AppColors.appGreenC,
                              AppColors.appDarkGreenC,
                            ],
                          ),
                        ),
                        _buildFeatureCard(
                          'Analytics',
                          'Track performance insights',
                          Icons.analytics_rounded,
                          const LinearGradient(
                            colors: [
                              AppColors.appDarkYellowC,
                              AppColors.appLightYellowC,
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // Recent Work Section
                    AppSectionHeader(
                      title: 'Continue Working',
                      action: TextButton.icon(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.appBlue,
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Text(
                          'View All',
                          style: AppStyle.style14w600(color: AppColors.appBlue),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildResumeCard(
                      'Software Engineer Resume',
                      'Last edited 2 hours ago',
                      0.85,
                      AppColors.appBlue,
                    ),
                    SizedBox(height: 12.h),
                    _buildResumeCard(
                      'Product Designer CV',
                      'Last edited yesterday',
                      0.60,
                      AppColors.appPurple,
                    ),
                    SizedBox(height: 12.h),
                    _buildResumeCard(
                      'Marketing Manager',
                      'Last edited 3 days ago',
                      0.45,
                      AppColors.appPink,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.startCardColor1.withValues(alpha: 0.8),
            AppColors.startCardColor2.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.whiteColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8.h),
          Text(value, style: AppStyle.style20w700(color: AppColors.whiteColor)),
          Text(
            label,
            style: AppStyle.style12w500(
              color: AppColors.whiteColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String subtitle,
    IconData icon,
    Gradient gradient,
  ) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.startCardColor1.withValues(alpha: 0.8),
            AppColors.startCardColor2.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.whiteColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CustomIcon(
              iconOnly: true,
              icon: icon,
              iconColor: AppColors.whiteColor,
              size: 28.r,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyle.style18w700(
                  color: AppColors.whiteColor,
                ).copyWith(overflow: TextOverflow.visible),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: AppStyle.style13w500(
                  color: AppColors.whiteColor.withValues(alpha: 0.6),
                ).copyWith(overflow: TextOverflow.visible),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumeCard(
    String title,
    String date,
    double progress,
    Color accentColor,
  ) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.resumeCardColor1.withValues(alpha: 0.8),
            AppColors.resumeCardColor2.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.whiteColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.3),
                      accentColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: CustomIcon(
                  iconOnly: true,
                  icon: Icons.description_rounded,
                  iconColor: accentColor,
                  size: 28.r,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppStyle.style17w600(color: AppColors.whiteColor),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      date,
                      style: AppStyle.style13w500(
                        color: AppColors.whiteColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: CustomIcon(
                  iconOnly: true,
                  icon: Icons.more_horiz_rounded,
                  iconColor: AppColors.whiteColor,
                  size: 20.r,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.whiteColor.withValues(
                      alpha: 0.1,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    minHeight: 8,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.3),
                      accentColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: AppStyle.style14w700(color: accentColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
