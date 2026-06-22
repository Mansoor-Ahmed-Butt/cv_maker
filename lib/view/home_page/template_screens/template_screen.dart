import 'package:flutter/material.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/widgets/common/app_shell.dart';
import 'package:flutter_with_hive/widgets/common/gradient_primary_button.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: AppEmptyState(
        icon: Icons.grid_view_rounded,
        title: 'Template gallery coming next',
        message:
            'This screen now uses the shared app shell and is ready for a reusable template grid component.',
        action: GradientPrimaryButton(
          onPressed: () {},
          text: 'Browse Featured',
          icon: Icons.auto_awesome_rounded,
          colors: const [AppColors.appPink, AppColors.appOrangeC],
          isExpanded: false,
        ),
      ),
    );
  }
}
