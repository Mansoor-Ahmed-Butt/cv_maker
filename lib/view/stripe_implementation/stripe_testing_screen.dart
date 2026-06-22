import 'package:flutter/material.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/view/stripe_implementation/stripe_testing_controller.dart';
import 'package:flutter_with_hive/widgets/common/app_shell.dart';
import 'package:flutter_with_hive/widgets/common/gradient_primary_button.dart';
import 'package:flutter_with_hive/widgets/text/app_style.dart';
import 'package:get/get.dart';

class StripeTestingScreen extends StatefulWidget {
  const StripeTestingScreen({super.key});

  @override
  State<StripeTestingScreen> createState() => _StripeTestingScreenState();
}

class _StripeTestingScreenState extends State<StripeTestingScreen> {
  final controller = Get.put(StripeTestingController());

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: AppGlassCard(
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Stripe Testing',
                    style: AppStyle.style30w700(color: AppColors.whiteColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This payment test screen now uses the shared shell and button components instead of the legacy form wrapper.',
                    style: AppStyle.style14w400(
                      color: AppColors.whiteColor.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientPrimaryButton(
                    onPressed: controller.isLoadingStripe.value
                        ? () {}
                        : () => controller.postStripeData(context, 3000),
                    text: controller.isLoadingStripe.value
                        ? 'Processing...'
                        : 'Pay Now',
                    icon: controller.isLoadingStripe.value
                        ? Icons.hourglass_top_rounded
                        : Icons.payment_rounded,
                    colors: controller.isLoadingStripe.value
                        ? const [AppColors.mutedText, AppColors.greyColor]
                        : const [AppColors.appBlue, AppColors.appPurple],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
