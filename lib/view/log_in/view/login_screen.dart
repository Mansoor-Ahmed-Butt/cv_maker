import 'package:flutter/material.dart';
import 'package:flutter_with_hive/core/app_router.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/view/log_in/controller/log_in_controller.dart';
import 'package:flutter_with_hive/widgets/common/app_auth_widgets.dart';
import 'package:flutter_with_hive/widgets/common/custom_app_text_field.dart';
import 'package:flutter_with_hive/widgets/common/gradient_primary_button.dart';
import 'package:flutter_with_hive/widgets/text/app_style.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LogInController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LogInController());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppAuthLayout(
        title: 'Welcome back',
        subtitle:
            'Sign in to continue building professional resumes with a consistent workflow.',
        form: Column(
          children: [
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
              hint: 'Enter your password',
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
              text: 'Log In',
              icon: Icons.arrow_forward_rounded,
            ),
          ],
        ),
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Need an account?',
              style: AppStyle.style14w400(
                color: AppColors.whiteColor.withValues(alpha: 0.72),
              ),
            ),
            TextButton(
              onPressed: () => context.go(RouteConfig.signUpScreenRoute),
              child: Text(
                'Sign Up',
                style: AppStyle.style14w600(color: AppColors.appBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
