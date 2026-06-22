import 'package:flutter/material.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/widgets/common/app_shell.dart';
import 'package:flutter_with_hive/widgets/common/gradient_primary_button.dart';

class MyResumesScreen extends StatelessWidget {
  const MyResumesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: AppEmptyState(
        icon: Icons.folder_copy_rounded,
        title: 'Your resume workspace is ready',
        message:
            'Saved drafts, exported CVs, and progress history can live here once the resume flow is connected.',
        action: GradientPrimaryButton(
          onPressed: () {},
          text: 'Create Resume',
          icon: Icons.add_rounded,
          colors: const [AppColors.appBlue, AppColors.appPurple],
          isExpanded: false,
        ),
      ),
    );
  }
}
