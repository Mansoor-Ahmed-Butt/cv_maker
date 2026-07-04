import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/view/resume_workflow/resume_models.dart';
import 'package:flutter_with_hive/view/resume_workflow/resume_workflow_screen.dart';
import 'package:flutter_with_hive/view/resume_workflow/resume_workspace_controller.dart';
import 'package:flutter_with_hive/widgets/common/app_shell.dart';
import 'package:flutter_with_hive/widgets/common/gradient_primary_button.dart';
import 'package:flutter_with_hive/widgets/text/app_style.dart';
import 'package:get/get.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ResumeWorkspaceController controller = Get.find<ResumeWorkspaceController>();

    return AppGradientScaffold(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Templates',
            style: AppStyle.style24w700(color: AppColors.whiteColor),
          ),
          SizedBox(height: 8.h),
          Text(
            'Pick a layout style, then upload your existing CV and continue editing inside the resume builder.',
            style: AppStyle.style14w400(
              color: AppColors.whiteColor.withValues(alpha: 0.74),
            ),
          ),
          SizedBox(height: 18.h),
          Expanded(
            child: GridView.builder(
              itemCount: ResumeTemplate.values.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 700 ? 2 : 1,
                childAspectRatio: 0.85,
                mainAxisSpacing: 14.h,
                crossAxisSpacing: 14.w,
              ),
              itemBuilder: (BuildContext context, int index) {
                final ResumeTemplate template = ResumeTemplate.values[index];
                return AppGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 140.h,
                        decoration: BoxDecoration(
                          gradient: _gradientForTemplate(template),
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: AppColors.whiteColor,
                          size: 42,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        template.label,
                        style: AppStyle.style18w700(color: AppColors.whiteColor),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        template.description,
                        style: AppStyle.style13w400(
                          color: AppColors.whiteColor.withValues(alpha: 0.72),
                        ),
                      ),
                      const Spacer(),
                      GradientPrimaryButton(
                        onPressed: () {
                          controller.selectTemplate(template);
                          controller.startFresh();
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ResumeWorkflowScreen(
                                startFresh: true,
                                initialStep: 0,
                              ),
                            ),
                          );
                        },
                        text: 'Use This Template',
                        icon: Icons.auto_awesome_rounded,
                        colors: const <Color>[AppColors.appPink, AppColors.appOrangeC],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _gradientForTemplate(ResumeTemplate template) {
    switch (template) {
      case ResumeTemplate.modern:
        return const LinearGradient(colors: <Color>[AppColors.appBlue, AppColors.appPurple]);
      case ResumeTemplate.classic:
        return const LinearGradient(colors: <Color>[Color(0xFF334155), Color(0xFF0F172A)]);
      case ResumeTemplate.minimal:
        return const LinearGradient(colors: <Color>[Color(0xFF94A3B8), Color(0xFFE2E8F0)]);
      case ResumeTemplate.creative:
        return const LinearGradient(colors: <Color>[AppColors.appPink, AppColors.appOrangeC]);
    }
  }
}
