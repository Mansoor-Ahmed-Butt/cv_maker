import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/view/home_page/main_home_screen_controller.dart';
import 'package:flutter_with_hive/widgets/text/app_style.dart';
import 'package:get/get.dart';
import 'package:flutter_with_hive/widgets/create_resume_alert/responsive_widget.dart';

// Main Screen with Bottom Navigation
class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MainHomeScreenController ctrl = Get.put(MainHomeScreenController());

    return ResponsiveWidget(
      mobile: Scaffold(
        extendBody: true,
        body: Obx(() => ctrl.screenBuilders[ctrl.currentIndex.value]()),
        bottomNavigationBar: _FloatingNavBar(controller: ctrl),
      ),

      tablet: Scaffold(
        extendBody: true,
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800.w),
            child: Obx(() => ctrl.screenBuilders[ctrl.currentIndex.value]()),
          ),
        ),
        bottomNavigationBar: _FloatingNavBar(controller: ctrl),
      ),

      desktop: Scaffold(
        body: Row(
          children: [
            Obx(
              () => NavigationRail(
                selectedIndex: ctrl.currentIndex.value,
                onDestinationSelected: ctrl.changePage,
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_rounded),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.grid_view_rounded),
                    label: Text('Templates'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.folder_open_rounded),
                    label: Text('My CVs'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_rounded),
                    label: Text('Profile'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() => ctrl.screenBuilders[ctrl.currentIndex.value]()),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Floating Nav Bar ──────────────────────────────────────────────────────────
// Extracted to its own widget so each _NavItem can use Obx independently.

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({required this.controller});
  final MainHomeScreenController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.r),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.bottomNavColor1.withValues(alpha: 0.95),
            AppColors.bottomNavColor2.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.bottomNavShadowColor1.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.bottomNavShadowColor2.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.1),
          width: 1.5.h,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'Home',
              controller: controller,
            ),
          ),
          Expanded(
            child: _NavItem(
              index: 1,
              icon: Icons.grid_view_rounded,
              label: 'Templates',
              controller: controller,
            ),
          ),
          _CenterFab(controller: controller),
          Expanded(
            child: _NavItem(
              index: 2,
              icon: Icons.folder_open_rounded,
              label: 'My CVs',
              controller: controller,
            ),
          ),
          Expanded(
            child: _NavItem(
              index: 3,
              icon: Icons.person_rounded,
              label: 'Profile',
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single nav item — uses Obx so selection state is always reactive ──────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.controller,
  });

  final int index;
  final IconData icon;
  final String label;
  final MainHomeScreenController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.currentIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changePage(index),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: isSelected ? 1 : 0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          builder: (context, value, _) {
            return Container(
              // No fixed horizontal padding — let Expanded handle width
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: value > 0
                    ? LinearGradient(
                        colors: [
                          Color.lerp(
                            AppColors.transparent,
                            AppColors.bottomNavCenterButtonColor1,
                            value,
                          )!.withValues(alpha: 0.2),
                          Color.lerp(
                            AppColors.transparent,
                            AppColors.bottomNavCenterButtonColor2,
                            value,
                          )!.withValues(alpha: 0.2),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: Color.lerp(
                      AppColors.bottomNavIconColor1,
                      AppColors.bottomNavIconColor2,
                      value,
                    ),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  if (value > 0.3)
                    Opacity(
                      opacity: value,
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyle.style10w600(
                          color: Color.lerp(
                            AppColors.transparent,
                            AppColors.bottomNavIconColor2,
                            value,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

// ── Center FAB — not a tab, just triggers an action ───────────────────────────

class _CenterFab extends StatelessWidget {
  const _CenterFab({required this.controller});
  final MainHomeScreenController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.bottomNavCenterButtonColor1,
            AppColors.bottomNavCenterButtonColor2,
            AppColors.bottonNavCenterButtonColor3,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.bottomNavCenterButtonShadowColor1.withValues(
              alpha: 0.6,
            ),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30.r),
          onTap: () {
            // TODO: hook up to resume creation dialog
          },
          child: Icon(
            Icons.add_rounded,
            color: AppColors.whiteColor,
            size: 32.r,
          ),
        ),
      ),
    );
  }
}
