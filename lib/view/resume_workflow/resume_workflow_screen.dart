import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/view/resume_workflow/resume_models.dart';
import 'package:flutter_with_hive/view/resume_workflow/resume_workspace_controller.dart';
import 'package:flutter_with_hive/widgets/common/app_shell.dart';
import 'package:flutter_with_hive/widgets/common/gradient_primary_button.dart';
import 'package:flutter_with_hive/widgets/text/app_style.dart';

class ResumeWorkflowScreen extends StatefulWidget {
  const ResumeWorkflowScreen({
    super.key,
    this.initialStep = 0,
    this.draftId,
    this.startFresh = false,
  });

  final int initialStep;
  final String? draftId;
  final bool startFresh;

  @override
  State<ResumeWorkflowScreen> createState() => _ResumeWorkflowScreenState();
}

class _ResumeWorkflowScreenState extends State<ResumeWorkflowScreen> {
  late final ResumeWorkspaceController _controller;
  late int _step;
  static const List<String> _stepTitles = <String>[
    'Upload CV',
    'Choose Template',
    'Complete Details',
    'Preview & Download',
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ResumeWorkspaceController>();
    _step = widget.initialStep.clamp(0, _stepTitles.length - 1);

    if (widget.startFresh) {
      _controller.startFresh();
    }
    if (widget.draftId != null) {
      _controller.openDraft(widget.draftId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ResumeDraft? draft = _controller.currentDraft.value;
      final List<String> issues =
          draft == null ? <String>[] : _controller.missingFields(draft);

      return Scaffold(
        backgroundColor: AppColors.homeBackgroundColor1,
        appBar: AppBar(
          backgroundColor: AppColors.homeBackgroundColor1,
          foregroundColor: AppColors.whiteColor,
          title: const Text('Resume Builder'),
          actions: <Widget>[
            if (draft != null)
              IconButton(
                tooltip: 'Delete draft',
                onPressed: () => _confirmDeleteDraft(draft),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.homeBackgroundGradient),
          child: SafeArea(
            top: false,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
                  child: _buildStepHeader(),
                ),
                if (_controller.statusMessage.value.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: AppGlassCard(
                      padding: EdgeInsets.all(14.r),
                      backgroundColor: AppColors.surfaceDark.withValues(alpha: 0.9),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.appBlue,
                            size: 20.r,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              _controller.statusMessage.value,
                              style: AppStyle.style13w500(
                                color: AppColors.whiteColor.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 12.h),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _buildStepBody(draft, issues),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
                  child: _buildFooter(draft),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStepHeader() {
    return Row(
      children: List<Widget>.generate(_stepTitles.length, (int index) {
        final bool isActive = index == _step;
        final bool isCompleted = index < _step;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                gradient: isActive || isCompleted
                    ? const LinearGradient(
                        colors: <Color>[AppColors.appBlue, AppColors.appPink],
                      )
                    : null,
                color: isActive || isCompleted
                    ? null
                    : AppColors.whiteColor.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.whiteColor.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${index + 1}',
                    style: AppStyle.style16w700(
                      color: AppColors.whiteColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _stepTitles[index],
                    textAlign: TextAlign.center,
                    style: AppStyle.style11w500(
                      color: AppColors.whiteColor.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepBody(ResumeDraft? draft, List<String> issues) {
    switch (_step) {
      case 0:
        return _buildUploadStep(draft);
      case 1:
        return _buildTemplateStep(draft);
      case 2:
        return _buildEditorStep(draft, issues);
      case 3:
        return _buildPreviewStep(draft, issues);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildUploadStep(ResumeDraft? draft) {
    return SingleChildScrollView(
      key: const ValueKey<int>(0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Upload your old CV',
                  style: AppStyle.style22w700(color: AppColors.whiteColor),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Select an existing PDF resume. The app will create a new editable draft, check missing fields, and move you into the new template flow.',
                  style: AppStyle.style14w400(
                    color: AppColors.whiteColor.withValues(alpha: 0.75),
                  ),
                ),
                SizedBox(height: 20.h),
                if (_controller.isParsing.value)
                  Center(
                    child: Column(
                      children: <Widget>[
                        const CircularProgressIndicator(color: AppColors.appBlue),
                        SizedBox(height: 14.h),
                        Text(
                          'Parsing your uploaded CV...',
                          style: AppStyle.style14w500(color: AppColors.whiteColor),
                        ),
                      ],
                    ),
                  )
                else
                  GradientPrimaryButton(
                    onPressed: () async {
                      final bool success = await _controller.importOldCv();
                      if (success && mounted) {
                        setState(() {
                          _step = 1;
                        });
                      }
                    },
                    text: draft == null ? 'Upload Old CV (PDF)' : 'Replace Uploaded CV',
                    icon: Icons.upload_file_rounded,
                  ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          if (draft != null)
            AppGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Current Upload',
                    style: AppStyle.style18w700(color: AppColors.whiteColor),
                  ),
                  SizedBox(height: 14.h),
                  _infoRow(Icons.picture_as_pdf_rounded, 'File', draft.originalFileName),
                  _infoRow(
                    Icons.auto_awesome_rounded,
                    'AI Parse',
                    draft.aiEnhanced ? 'Gemini prefill applied' : 'Manual completion mode',
                  ),
                  _infoRow(
                    Icons.calendar_today_rounded,
                    'Updated',
                    DateFormat('dd MMM yyyy, hh:mm a').format(draft.updatedAt),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmDeleteDraft(draft),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Delete Draft'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.whiteColor,
                            side: BorderSide(
                              color: AppColors.whiteColor.withValues(alpha: 0.18),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: GradientPrimaryButton(
                          onPressed: () => setState(() => _step = 1),
                          text: 'Choose Template',
                          icon: Icons.arrow_forward_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTemplateStep(ResumeDraft? draft) {
    if (draft == null) {
      return _lockedStep('Upload an old CV first to unlock template selection.');
    }

    return SingleChildScrollView(
      key: const ValueKey<int>(1),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Select a new template',
            style: AppStyle.style22w700(color: AppColors.whiteColor),
          ),
          SizedBox(height: 8.h),
          Text(
            'Choose how the new resume should look before you review missing fields and edit the content.',
            style: AppStyle.style14w400(
              color: AppColors.whiteColor.withValues(alpha: 0.75),
            ),
          ),
          SizedBox(height: 18.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ResumeTemplate.values.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 700 ? 2 : 1,
              childAspectRatio: 1.35,
              mainAxisSpacing: 14.h,
              crossAxisSpacing: 14.w,
            ),
            itemBuilder: (BuildContext context, int index) {
              final ResumeTemplate template = ResumeTemplate.values[index];
              final bool selected = draft.template == template;
              return InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () {
                  _controller.selectTemplate(template);
                  setState(() {});
                },
                child: AppGlassCard(
                  borderRadius: 20,
                  backgroundColor: selected
                      ? AppColors.appBlue.withValues(alpha: 0.22)
                      : AppColors.surfaceDark.withValues(alpha: 0.82),
                  borderColor: selected
                      ? AppColors.appBlue
                      : AppColors.whiteColor.withValues(alpha: 0.08),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 44.w,
                            height: 44.h,
                            decoration: BoxDecoration(
                              gradient: _templateGradient(template),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              color: AppColors.whiteColor,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: selected
                                ? AppColors.appGreenC
                                : AppColors.whiteColor.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
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
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditorStep(ResumeDraft? draft, List<String> issues) {
    if (draft == null) {
      return _lockedStep('Upload an old CV and select a template before editing.');
    }

    return SingleChildScrollView(
      key: const ValueKey<int>(2),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (issues.isNotEmpty)
            AppGlassCard(
              backgroundColor: AppColors.appOrangeC.withValues(alpha: 0.12),
              borderColor: AppColors.appOrangeC.withValues(alpha: 0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Missing fields detected',
                    style: AppStyle.style18w700(color: AppColors.whiteColor),
                  ),
                  SizedBox(height: 10.h),
                  ...issues.map(
                    (String issue) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.appOrangeC,
                            size: 18.r,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              issue,
                              style: AppStyle.style13w500(
                                color: AppColors.whiteColor.withValues(alpha: 0.88),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (issues.isNotEmpty) SizedBox(height: 16.h),
          _sectionTitle('Personal Information'),
          AppGlassCard(
            child: Column(
              children: <Widget>[
                _buildTextField(
                  label: 'Full name',
                  initialValue: draft.resume.name,
                  onChanged: (String value) => _markDirty(
                    () => _controller.updatePersonalInfo(name: value),
                  ),
                ),
                _buildTextField(
                  label: 'Email',
                  initialValue: draft.resume.email,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (String value) => _markDirty(
                    () => _controller.updatePersonalInfo(email: value),
                  ),
                ),
                _buildTextField(
                  label: 'Phone',
                  initialValue: draft.resume.phone,
                  keyboardType: TextInputType.phone,
                  onChanged: (String value) => _markDirty(
                    () => _controller.updatePersonalInfo(phone: value),
                  ),
                ),
                _buildTextField(
                  label: 'Location',
                  initialValue: draft.resume.location,
                  onChanged: (String value) => _markDirty(
                    () => _controller.updatePersonalInfo(location: value),
                  ),
                ),
                _buildTextField(
                  label: 'Job title',
                  initialValue: draft.resume.jobTitle,
                  onChanged: (String value) => _markDirty(
                    () => _controller.updatePersonalInfo(jobTitle: value),
                  ),
                ),
                _buildTextField(
                  label: 'Summary',
                  initialValue: draft.resume.summary,
                  maxLines: 4,
                  onChanged: (String value) => _markDirty(
                    () => _controller.updatePersonalInfo(summary: value),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _sectionTitle('Skills & Languages'),
          AppGlassCard(
            child: Column(
              children: <Widget>[
                _buildTextField(
                  label: 'Skills (comma separated)',
                  initialValue: draft.resume.skills.join(', '),
                  onChanged: (String value) => _markDirty(
                    () => _controller.updateSkills(value),
                  ),
                ),
                _buildTextField(
                  label: 'Languages (comma separated)',
                  initialValue: draft.resume.languages.join(', '),
                  onChanged: (String value) => _markDirty(
                    () => _controller.updateLanguages(value),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _buildExperienceSection(draft),
          SizedBox(height: 16.h),
          _buildEducationSection(draft),
          SizedBox(height: 16.h),
          _buildProjectsSection(draft),
          SizedBox(height: 20.h),
          GradientPrimaryButton(
            onPressed: () => setState(() => _step = 3),
            text: 'Preview Resume',
            icon: Icons.visibility_outlined,
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildPreviewStep(ResumeDraft? draft, List<String> issues) {
    if (draft == null) {
      return _lockedStep('Upload, select a template, and edit your resume before previewing.');
    }

    return Column(
      key: const ValueKey<int>(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Preview the final resume',
                style: AppStyle.style20w700(color: AppColors.whiteColor),
              ),
              SizedBox(height: 8.h),
              Text(
                issues.isEmpty
                    ? 'Everything looks ready. Preview and download the final PDF.'
                    : 'You can still download the file, but completing the missing fields will improve the result.',
                style: AppStyle.style14w400(
                  color: AppColors.whiteColor.withValues(alpha: 0.75),
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _step = 2),
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text('Back to Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.whiteColor,
                        side: BorderSide(
                          color: AppColors.whiteColor.withValues(alpha: 0.18),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GradientPrimaryButton(
                      onPressed: () async {
                        final Uint8List bytes = await _controller.buildPdf();
                        final String fileName =
                            '${draft.displayName.replaceAll(' ', '_')}.pdf';
                        await Printing.sharePdf(bytes: bytes, filename: fileName);
                      },
                      text: 'Download / Share',
                      icon: Icons.download_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: PdfPreview(
              allowPrinting: true,
              allowSharing: true,
              canDebug: false,
              pdfFileName: '${draft.displayName.replaceAll(' ', '_')}.pdf',
              build: (PdfPageFormat format) => _controller.buildPdf(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceSection(ResumeDraft draft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _sectionTitle('Experience')),
            TextButton.icon(
              onPressed: () => _markDirty(_controller.addExperience),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            ),
          ],
        ),
        AppGlassCard(
          child: Column(
            children: draft.resume.experience.isEmpty
                ? <Widget>[
                    Text(
                      'No experience added yet.',
                      style: AppStyle.style14w400(
                        color: AppColors.whiteColor.withValues(alpha: 0.72),
                      ),
                    ),
                  ]
                : draft.resume.experience.asMap().entries.map((MapEntry<int, Experience> entry) {
                    final int index = entry.key;
                    final Experience item = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == draft.resume.experience.length - 1 ? 0 : 16.h),
                      child: _entryCard(
                        title: 'Experience ${index + 1}',
                        onRemove: () => _markDirty(() => _controller.removeExperience(index)),
                        children: <Widget>[
                          _buildTextField(
                            label: 'Role title',
                            initialValue: item.title,
                            onChanged: (String value) => _markDirty(
                              () => _controller.updateExperience(index, title: value),
                            ),
                          ),
                          _buildTextField(
                            label: 'Company',
                            initialValue: item.company,
                            onChanged: (String value) => _markDirty(
                              () => _controller.updateExperience(index, company: value),
                            ),
                          ),
                          _buildTextField(
                            label: 'Duration',
                            initialValue: item.duration,
                            onChanged: (String value) => _markDirty(
                              () => _controller.updateExperience(index, duration: value),
                            ),
                          ),
                          _buildTextField(
                            label: 'Description',
                            initialValue: item.description,
                            maxLines: 3,
                            onChanged: (String value) => _markDirty(
                              () => _controller.updateExperience(index, description: value),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationSection(ResumeDraft draft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _sectionTitle('Education')),
            TextButton.icon(
              onPressed: () => _markDirty(_controller.addEducation),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            ),
          ],
        ),
        AppGlassCard(
          child: Column(
            children: draft.resume.education.isEmpty
                ? <Widget>[
                    Text(
                      'No education added yet.',
                      style: AppStyle.style14w400(
                        color: AppColors.whiteColor.withValues(alpha: 0.72),
                      ),
                    ),
                  ]
                : draft.resume.education.asMap().entries.map((MapEntry<int, Education> entry) {
                    final int index = entry.key;
                    final Education item = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == draft.resume.education.length - 1 ? 0 : 16.h),
                      child: _entryCard(
                        title: 'Education ${index + 1}',
                        onRemove: () => _markDirty(() => _controller.removeEducation(index)),
                        children: <Widget>[
                          _buildTextField(
                            label: 'Degree',
                            initialValue: item.degree,
                            onChanged: (String value) => _markDirty(
                              () => _controller.updateEducation(index, degree: value),
                            ),
                          ),
                          _buildTextField(
                            label: 'Institution',
                            initialValue: item.institution,
                            onChanged: (String value) => _markDirty(
                              () => _controller.updateEducation(index, institution: value),
                            ),
                          ),
                          _buildTextField(
                            label: 'Year',
                            initialValue: item.year,
                            onChanged: (String value) => _markDirty(
                              () => _controller.updateEducation(index, year: value),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectsSection(ResumeDraft draft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _sectionTitle('Projects')),
            TextButton.icon(
              onPressed: () => _markDirty(_controller.addProject),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            ),
          ],
        ),
        AppGlassCard(
          child: Column(
            children: draft.resume.projects.isEmpty
                ? <Widget>[
                    Text(
                      'Projects are optional, but useful for showcasing real work.',
                      style: AppStyle.style14w400(
                        color: AppColors.whiteColor.withValues(alpha: 0.72),
                      ),
                    ),
                  ]
                : draft.resume.projects.asMap().entries.map((MapEntry<int, Project> entry) {
                    final int index = entry.key;
                    final Project item = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == draft.resume.projects.length - 1 ? 0 : 16.h),
                      child: _entryCard(
                        title: 'Project ${index + 1}',
                        onRemove: () => _markDirty(() => _controller.removeProject(index)),
                        children: <Widget>[
                          _buildTextField(
                            label: 'Project name',
                            initialValue: item.name,
                            onChanged: (String value) => _markDirty(
                              () => _controller.updateProject(index, name: value),
                            ),
                          ),
                          _buildTextField(
                            label: 'Tech stack',
                            initialValue: item.tech,
                            onChanged: (String value) => _markDirty(
                              () => _controller.updateProject(index, tech: value),
                            ),
                          ),
                          _buildTextField(
                            label: 'Description',
                            initialValue: item.description,
                            maxLines: 3,
                            onChanged: (String value) => _markDirty(
                              () => _controller.updateProject(index, description: value),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        title,
        style: AppStyle.style18w700(color: AppColors.whiteColor),
      ),
    );
  }

  Widget _entryCard({
    required String title,
    required List<Widget> children,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.whiteColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: AppStyle.style16w700(color: AppColors.whiteColor),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.appPink,
                  size: 20.r,
                ),
              ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: AppStyle.style14w500(color: AppColors.whiteColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppStyle.style13w500(
            color: AppColors.whiteColor.withValues(alpha: 0.65),
          ),
          filled: true,
          fillColor: AppColors.whiteColor.withValues(alpha: 0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(
              color: AppColors.whiteColor.withValues(alpha: 0.08),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(
              color: AppColors.whiteColor.withValues(alpha: 0.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: const BorderSide(color: AppColors.appBlue),
          ),
        ),
      ),
    );
  }

  Widget _lockedStep(String message) {
    return Center(
      child: AppEmptyState(
        icon: Icons.lock_outline_rounded,
        title: 'Step Locked',
        message: message,
      ),
    );
  }

  Widget _buildFooter(ResumeDraft? draft) {
    final bool canContinue = draft != null || _step == 0;

    return Row(
      children: <Widget>[
        if (_step > 0)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _step -= 1),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.whiteColor,
                side: BorderSide(
                  color: AppColors.whiteColor.withValues(alpha: 0.18),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
          ),
        if (_step > 0) SizedBox(width: 12.w),
        Expanded(
          child: GradientPrimaryButton(
            onPressed: canContinue ? _handlePrimaryAction : () {},
            text: _primaryLabel,
            icon: _primaryIcon,
          ),
        ),
      ],
    );
  }

  String get _primaryLabel {
    switch (_step) {
      case 0:
        return 'Upload CV';
      case 1:
        return 'Continue to Edit';
      case 2:
        return 'Preview Resume';
      case 3:
        return 'Start New Resume';
      default:
        return 'Continue';
    }
  }

  IconData get _primaryIcon {
    switch (_step) {
      case 0:
        return Icons.upload_file_rounded;
      case 1:
        return Icons.arrow_forward_rounded;
      case 2:
        return Icons.visibility_outlined;
      case 3:
        return Icons.refresh_rounded;
      default:
        return Icons.arrow_forward_rounded;
    }
  }

  Future<void> _handlePrimaryAction() async {
    switch (_step) {
      case 0:
        final bool success = await _controller.importOldCv();
        if (success && mounted) {
          setState(() => _step = 1);
        }
        break;
      case 1:
        if (_controller.currentDraft.value != null) {
          setState(() => _step = 2);
        }
        break;
      case 2:
        if (_controller.currentDraft.value != null) {
          setState(() => _step = 3);
        }
        break;
      case 3:
        _controller.startFresh();
        if (mounted) {
          setState(() => _step = 0);
        }
        break;
    }
  }

  void _markDirty(VoidCallback action) {
    action();
    setState(() {});
  }

  Future<void> _confirmDeleteDraft(ResumeDraft draft) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete this draft?'),
          content: Text(
            'The uploaded CV and edited resume data for "${draft.displayName}" will be removed from My CVs.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      _controller.deleteDraft(draft.id);
      if (_controller.currentDraft.value == null) {
        setState(() => _step = 0);
      }
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppColors.appBlue, size: 18.r),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppStyle.style13w500(
                  color: AppColors.whiteColor.withValues(alpha: 0.88),
                ),
                children: <TextSpan>[
                  TextSpan(text: '$label: '),
                  TextSpan(
                    text: value,
                    style: AppStyle.style13w400(
                      color: AppColors.whiteColor.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _templateGradient(ResumeTemplate template) {
    switch (template) {
      case ResumeTemplate.modern:
        return const LinearGradient(colors: <Color>[AppColors.appBlue, AppColors.appPurple]);
      case ResumeTemplate.classic:
        return const LinearGradient(colors: <Color>[Color(0xFF334155), Color(0xFF0F172A)]);
      case ResumeTemplate.minimal:
        return const LinearGradient(colors: <Color>[Color(0xFF64748B), Color(0xFFCBD5E1)]);
      case ResumeTemplate.creative:
        return const LinearGradient(colors: <Color>[AppColors.appPink, AppColors.appOrangeC]);
    }
  }
}
