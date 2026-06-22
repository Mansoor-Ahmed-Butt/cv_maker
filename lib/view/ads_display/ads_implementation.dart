import 'package:flutter/material.dart';
import 'package:flutter_with_hive/view/ads_display/ads_implement_controller.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/widgets/common/app_shell.dart';
import 'package:flutter_with_hive/widgets/common/gradient_primary_button.dart';
import 'package:flutter_with_hive/widgets/text/app_style.dart';
import 'package:get/get.dart';

class AdsImplementationScreen extends StatefulWidget {
  const AdsImplementationScreen({super.key});

  @override
  State<AdsImplementationScreen> createState() =>
      _AdsImplementationScreenState();
}

class _AdsImplementationScreenState extends State<AdsImplementationScreen> {
  final controller = Get.put(AdsImplementController());

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: AppGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ads Playground',
                  style: AppStyle.style30w700(color: AppColors.whiteColor),
                ),
                const SizedBox(height: 12),
                Text(
                  'Use the shared component system while testing interstitial, rewarded, and banner ads.',
                  style: AppStyle.style14w400(
                    color: AppColors.whiteColor.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 24),
                GradientPrimaryButton(
                  onPressed: () {
                    controller.showInterstitial();
                    Get.snackbar(
                      'Ads',
                      'Requested interstitial ad',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  text: 'Show Interstitial',
                  icon: Icons.smart_display_rounded,
                ),
                const SizedBox(height: 16),
                GradientPrimaryButton(
                  onPressed: () {
                    controller.showRewarded(() {
                      Get.snackbar('Reward', 'You earned a reward');
                    });
                    Get.snackbar(
                      'Ads',
                      'Requested rewarded ad',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  text: 'Show Rewarded',
                  icon: Icons.card_giftcard_rounded,
                  colors: const [AppColors.appPink, AppColors.appOrangeC],
                ),
                const SizedBox(height: 16),
                GradientPrimaryButton(
                  onPressed: controller.loadBanner,
                  text: 'Load Banner',
                  icon: Icons.view_agenda_rounded,
                  colors: const [AppColors.appGreenC, AppColors.appDarkGreenC],
                ),
                const SizedBox(height: 24),
                controller.showBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
