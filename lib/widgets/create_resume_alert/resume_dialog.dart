import 'package:flutter/material.dart';

import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/view/home_page/main_home_screen_controller.dart';
import 'package:flutter_with_hive/widgets/common/custom_app_text_field.dart';
import 'package:flutter_with_hive/widgets/common/gradient_primary_button.dart';
import 'package:flutter_with_hive/widgets/text/app_style.dart';
import 'package:get/get.dart';

// GetX Controller for Resume Dialog
class ResumeDialogController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController headerAnimController;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void onClose() {
    headerAnimController.dispose();
    super.onClose();
  }

  bool validateAndSubmit() {
    if (formKey.currentState!.validate()) {
      Get.back();
      Get.snackbar(
        'Success',
        'Resume created successfully!',
        backgroundColor: AppColors.success,
        colorText: AppColors.whiteColor,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return true;
    }
    return false;
  }
}

// Premium Alert Dialog with Glassmorphism and Smooth Animations
Future<dynamic> showPremiumResumeDialog(
  BuildContext context, {
  bool isEditMode = false,
  int? index,
  int? addressId,
}) async {
  // Initialize controller with fenix: true for automatic disposal when no longer used
  // This prevents premature deletion errors
  final controller = Get.put(ResumeDialogController(), permanent: false);

  try {
    final result = await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Resume Dialog',
      barrierColor: AppColors.blackColor.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: Center(
              child: _PremiumResumeDialog(
                isEditMode: isEditMode,
                index: index,
                addressId: addressId,
                controller: controller,
              ),
            ),
          ),
        );
      },
    );

    return result;
  } finally {
    // Clean up controller after dialog closes and animations complete
    // Use Future.microtask to ensure it runs after current frame
    Future.microtask(() {
      if (Get.isRegistered<ResumeDialogController>()) {
        Get.delete<ResumeDialogController>();
      }
    });
  }
}

class _PremiumResumeDialog extends StatelessWidget {
  final bool isEditMode;
  final int? index;
  final int? addressId;
  final ResumeDialogController controller;

  const _PremiumResumeDialog({
    this.isEditMode = false,
    this.index,
    this.addressId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.appBlue.withValues(alpha: 0.3),
              blurRadius: 60,
              spreadRadius: 10,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: AppColors.blackColor.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPremiumHeader(context, controller),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileSection(),
                        const SizedBox(height: 32),
                        CustomAppTextField(
                          controller:
                              MainHomeScreenController.to.nameController,
                          label: 'Full Name',
                          icon: Icons.person_rounded,
                          hint: 'e.g., John Smith',
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 20),
                        CustomAppTextField(
                          controller:
                              MainHomeScreenController.to.jobTitleController,
                          label: 'Job Title',
                          icon: Icons.work_rounded,
                          hint: 'e.g., Senior Software Engineer',
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: CustomAppTextField(
                                controller:
                                    MainHomeScreenController.to.emailController,
                                label: 'Email',
                                icon: Icons.email_rounded,
                                hint: 'john@example.com',
                                keyboardType: TextInputType.emailAddress,
                                // Custom email validator
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Email is required';
                                  if (!value.contains('@'))
                                    return 'Please enter a valid email';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomAppTextField(
                                controller:
                                    MainHomeScreenController.to.phoneController,
                                label: 'Phone',
                                icon: Icons.phone_rounded,
                                hint: '+1 234 567 890',
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomAppTextField(
                          controller:
                              MainHomeScreenController.to.locationController,
                          label: 'Location',
                          icon: Icons.location_on_rounded,
                          hint: 'e.g., New York, USA',
                        ),
                        const SizedBox(height: 20),
                        CustomAppTextField(
                          controller:
                              MainHomeScreenController.to.summaryController,
                          label: 'Professional Summary',
                          icon: Icons.article_rounded,
                          hint: 'Tell us about your professional background...',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 32),
                        _buildActionButtons(context, controller),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(
    BuildContext context,
    ResumeDialogController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
      decoration: BoxDecoration(
        gradient: AppColors.primaryAccentGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.appBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: controller.headerAnimController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (0.1 * controller.headerAnimController.value),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blackColor.withValues(alpha: 0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.whiteColor,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Resume',
                  style: AppStyle.style24w700(color: AppColors.whiteColor)
                      .copyWith(
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: AppColors.blackColor.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                ),
                SizedBox(height: 6),
                Text(
                  'Build your professional profile',
                  style: AppStyle.style14w500(
                    color: AppColors.whiteColor.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.whiteColor,
                size: 24,
              ),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              await MainHomeScreenController.to.pickImage();
            },
            child: Stack(
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.appBlue.withValues(alpha: 0.2),
                        AppColors.appPink.withValues(alpha: 0.2),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.appBlue.withValues(alpha: 0.4),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.appBlue.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Obx(
                      () =>
                          MainHomeScreenController.to.profileImage.value != null
                          ? Image.file(
                              MainHomeScreenController.to.profileImage.value!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.appBlue.withValues(alpha: 0.1),
                                    AppColors.appPink.withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 60,
                                color: AppColors.appBlue,
                              ),
                            ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.appBlue, AppColors.appPurple],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.whiteColor, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.appBlue.withValues(alpha: 0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 20,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _UploadPhotoLabel(),
        ],
      ),
    );
  }

  // Removed old _buildPremiumTextField in favor of reusable CustomAppTextField

  Widget _buildActionButtons(
    BuildContext context,
    ResumeDialogController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.mutedText,
              side: const BorderSide(color: AppColors.borderColor, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Cancel',
              style: AppStyle.style16w700(color: AppColors.mutedText),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: GradientPrimaryButton(
            onPressed: () => controller.validateAndSubmit(),
            text: 'Create Resume',
            icon: Icons.check_circle_rounded,
          ),
        ),
      ],
    );
  }
}

// Optimized helper widgets with const constructors
class _UploadPhotoLabel extends StatelessWidget {
  const _UploadPhotoLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.appBlue.withValues(alpha: 0.1),
            AppColors.appPink.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.appBlue.withValues(alpha: 0.3)),
      ),
      child: Text(
        'Upload Photo',
        style: AppStyle.style15w600(color: AppColors.appBlue),
      ),
    );
  }
}
