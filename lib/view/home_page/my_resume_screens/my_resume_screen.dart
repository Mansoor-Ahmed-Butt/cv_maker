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

class MyResumesScreen extends StatelessWidget {
  const MyResumesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ResumeWorkspaceController controller = Get.find<ResumeWorkspaceController>();

    return AppGradientScaffold(
      padding: EdgeInsets.all(20.r),
      child: Obx(() {
        if (controller.drafts.isEmpty) {
          return AppEmptyState(
            icon: Icons.folder_copy_rounded,
            title: 'Your resume workspace is ready',
            message:
                'Upload an old CV, edit the missing fields, choose a template, and keep every draft here.',
            action: GradientPrimaryButton(
              onPressed: () {
                controller.startFresh();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ResumeWorkflowScreen(startFresh: true),
                  ),
                );
              },
              text: 'Create Resume',
              icon: Icons.add_rounded,
              colors: const <Color>[AppColors.appBlue, AppColors.appPurple],
              isExpanded: false,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'My CVs',
                    style: AppStyle.style24w700(color: AppColors.whiteColor),
                  ),
                ),
                GradientPrimaryButton(
                  onPressed: () {
                    controller.startFresh();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ResumeWorkflowScreen(startFresh: true),
                      ),
                    );
                  },
                  text: 'New Resume',
                  icon: Icons.add_rounded,
                  isExpanded: false,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.separated(
                itemCount: controller.drafts.length,
                separatorBuilder: (_, __) => SizedBox(height: 14.h),
                itemBuilder: (BuildContext context, int index) {
                  final ResumeDraft draft = controller.drafts[index];
                  return AppGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                draft.displayName,
                                style: AppStyle.style18w700(color: AppColors.whiteColor),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: AppColors.appBlue.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                draft.template.label,
                                style: AppStyle.style12w600(color: AppColors.whiteColor),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          draft.originalFileName,
                          style: AppStyle.style13w400(
                            color: AppColors.whiteColor.withValues(alpha: 0.68),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Missing fields: ${controller.missingFields(draft).length}',
                          style: AppStyle.style13w500(
                            color: AppColors.whiteColor.withValues(alpha: 0.78),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  controller.openDraft(draft.id);
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ResumeWorkflowScreen(
                                        draftId: draft.id,
                                        initialStep: 2,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Edit'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.whiteColor,
                                  side: BorderSide(
                                    color: AppColors.whiteColor.withValues(alpha: 0.16),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: GradientPrimaryButton(
                                onPressed: () {
                                  controller.openDraft(draft.id);
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ResumeWorkflowScreen(
                                        draftId: draft.id,
                                        initialStep: 3,
                                      ),
                                    ),
                                  );
                                },
                                text: 'Preview',
                                icon: Icons.visibility_outlined,
                                isExpanded: true,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () => controller.deleteDraft(draft.id),
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.appPink,
                                size: 24.r,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
