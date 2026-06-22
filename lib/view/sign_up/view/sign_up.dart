import 'package:flutter/material.dart';
import 'package:flutter_with_hive/core/app_router.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/view/sign_up/controller/sign_up_controller.dart';
import 'package:flutter_with_hive/widgets/common/app_auth_widgets.dart';
import 'package:flutter_with_hive/widgets/common/custom_app_text_field.dart';
import 'package:flutter_with_hive/widgets/common/gradient_primary_button.dart';
import 'package:flutter_with_hive/widgets/text/app_style.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late final SignUpController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SignUpController());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppAuthLayout(
        title: 'Create account',
        subtitle:
            'Set up your profile once and reuse a polished resume workflow across the app.',
        form: Column(
          children: [
            CustomAppTextField(
              controller: controller.userName,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Full name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomAppTextField(
              controller: controller.emailController,
              label: 'Email',
              hint: 'Enter your email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!GetUtils.isEmail(value.trim())) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomAppTextField(
              controller: controller.passwordController,
              label: 'Password',
              hint: 'Create a secure password',
              icon: Icons.lock_outline_rounded,
              obscureText: !controller.isPasswordVisible.value,
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                onPressed: controller.togglePasswordVisibility,
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.bodyText,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Password is required';
                }
                if (value.trim().length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            GradientPrimaryButton(
              onPressed: () {},
              text: 'Create Account',
              icon: Icons.person_add_alt_1_rounded,
            ),
          ],
        ),
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account?',
              style: AppStyle.style14w400(
                color: AppColors.whiteColor.withValues(alpha: 0.72),
              ),
            ),
            TextButton(
              onPressed: () => context.go(RouteConfig.loginScreenRoute),
              child: Text(
                'Log In',
                style: AppStyle.style14w600(color: AppColors.appBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
