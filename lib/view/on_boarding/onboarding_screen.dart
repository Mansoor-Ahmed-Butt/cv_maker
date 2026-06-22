import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/view/on_boarding/onboarding_model.dart';
import 'package:flutter_with_hive/view/on_boarding/onboarding_controller.dart';
import 'package:flutter_with_hive/widgets/animated_back_ground_circle_widget.dart';
import 'package:flutter_with_hive/widgets/animated_container.dart';
import 'package:flutter_with_hive/widgets/animated_text_shader.dart';
import 'package:flutter_with_hive/widgets/text/app_style.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

// Onboarding Screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.put(OnboardingController());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.homeBackgroundColor1, AppColors.homeBackgroundColor2, AppColors.homeBackgroundColor3],
          ),
        ),
        child: Stack(
          children: [
            // Animated Background Circles
            CustomBgAnimatedWidget(
              rotationController: _rotationController,
              top: -100,
              right: -100,
              width: 300.w,
              height: 300.h,
              color: AppColors.appBlue,
              opacity: 0.15,
              clockwise: true,
            ),
            CustomBgAnimatedWidget(
              rotationController: _rotationController,
              top: -150,
              right: -100,
              width: 400.w,
              height: 400.h,
              color: AppColors.appPink,
              opacity: 0.1,
              clockwise: true,
            ),

            SafeArea(
              child: Column(
                children: [
                  // Skip Button
                  Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedTextShader(
                          text: "CV Generator Pro",
                          style: AppStyle.style22w700(color: AppColors.whiteColor),
                        ),
                        Obx(
                          () => controller.currentPage.value < 2
                              ? TextButton(
                                  onPressed: () => controller.skipToEnd(context),
                                  style: TextButton.styleFrom(foregroundColor: AppColors.whiteColor.withValues(alpha: 0.7)),
                                  child: const Text('Skip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),

                  // PageView
                  Expanded(
                    child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: (index) {
                        controller.currentPage.value = index;
                      },
                      itemCount: controller.pages.length,
                      itemBuilder: (context, index) {
                        return _buildOnboardingPage(controller.pages[index]);
                      },
                    ),
                  ),

                  // Bottom Section
                  Padding(
                    padding: EdgeInsets.all(30.r),
                    child: Column(
                      children: [
                        // Page Indicator
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              controller.pages.length,
                              (index) => _buildPageIndicator(index, controller.currentPage.value, controller.pages[index].accentColor),
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Next/Get Started Button
                        Obx(
                          () => AnimatedGradientButton(
                            gradient: controller.pages[controller.currentPage.value].gradient,
                            accentColor: controller.pages[controller.currentPage.value].accentColor,
                            label: controller.currentPage.value < 2 ? 'Next' : 'Get Started',
                            icon: Icons.arrow_forward_rounded,
                            onTap: () {
                              controller.nextPage(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Animation with Gradient Container
          Container(
            width: 320.w,
            height: 320.h,
            decoration: BoxDecoration(
              gradient: RadialGradient(colors: [data.accentColor.withValues(alpha: 0.2), Colors.transparent]),
              shape: BoxShape.circle,
            ),
            child: Lottie.asset(data.lottieUrl, height: 250.h),
            // Lottie.network(
            //   data.lottieUrl,
            //   fit: BoxFit.contain,
            //   errorBuilder: (context, error, stackTrace) {
            //     // Fallback to icon if Lottie fails to load
            //     return Container(
            //       decoration: BoxDecoration(gradient: data.gradient, shape: BoxShape.circle),
            //       child: Icon(Icons.workspace_premium_rounded, size: 120.r, color: Colors.white),
            //     );
            //   },
            // ),
          ),
          SizedBox(height: 60.h),
          AnimatedTextShader(
            text: data.title,
            style: AppStyle.style28w700(color: AppColors.whiteColor).copyWith(height: 1.2),
            beginColor1: AppColors.appYellowC,
            endColor1: AppColors.appPink,
          ),

          SizedBox(height: 20.h),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: AppStyle.style16w400(color: AppColors.whiteColor.withValues(alpha: 0.7)).copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index, int currentIndex, Color color) {
    final isActive = index == currentIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        color: isActive ? color : AppColors.whiteColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)] : null,
      ),
    );
  }
}

// Placeholder Home Screen (Replace with your actual home screen)

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF2D1B69)],
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ShaderMask(
//                 shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFEC4899)]).createShader(bounds),
//                 child: const Icon(Icons.check_circle_rounded, size: 100, color: Colors.white),
//               ),
//               const SizedBox(height: 30),
//               const Text(
//                 'Welcome to CV Maker Pro!',
//                 style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 15),
//               Text('You\'re all set to create amazing resumes', style: TextStyle(color: AppColors.whiteColor.withValues(alpha: 0.7), fontSize: 16)),
//               const SizedBox(height: 50),
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 30),
//                 width: double.infinity,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))],
//                 ),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(20),
//                     onTap: () {
//                       // Navigate to your main app screen
//                       Get.snackbar(
//                         'Success',
//                         'Navigate to main app here!',
//                         backgroundColor: Colors.green,
//                         colorText: Colors.white,
//                         snackPosition: SnackPosition.BOTTOM,
//                       );
//                     },
//                     child: const Center(
//                       child: Text(
//                         'Start Creating',
//                         style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
