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
  bool _isSaving = false;

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

  // ── Step Header ─────────────────────────────────────────────────────────────

  Widget _buildStepHeader() {
    return Row(
      children: List<Widget>.generate(_stepTitles.length, (int index) {
        final bool isActive = index == _step;
        final bool isCompleted = index < _step;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
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
                  if (isCompleted)
                    Icon(Icons.check_rounded, color: AppColors.whiteColor, size: 16.r)
                  else
                    Text(
                      '${index + 1}',
                      style: AppStyle.style14w700(color: AppColors.whiteColor),
                    ),
                  SizedBox(height: 3.h),
                  Text(
                    _stepTitles[index],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyle.style10w600(
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

  // ── Step Body Router ─────────────────────────────────────────────────────────

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

  // ── Step 0 – Upload ──────────────────────────────────────────────────────────

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

  // ── Step 1 – Template ────────────────────────────────────────────────────────

  Widget _buildTemplateStep(ResumeDraft? draft) {
    if (draft == null) {
      return _lockedStep('Upload an old CV first to unlock template selection.');
    }

    final int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 2 : 2;

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
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.72,
              mainAxisSpacing: 14.h,
              crossAxisSpacing: 14.w,
            ),
            itemBuilder: (BuildContext context, int index) {
              final ResumeTemplate template = ResumeTemplate.values[index];
              final bool selected = draft.template == template;
              return GestureDetector(
                onTap: () {
                  _controller.selectTemplate(template);
                  setState(() {});
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: selected ? AppColors.appBlue : AppColors.whiteColor.withValues(alpha: 0.12),
                      width: selected ? 2.5 : 1,
                    ),
                    color: selected
                        ? AppColors.appBlue.withValues(alpha: 0.1)
                        : AppColors.whiteColor.withValues(alpha: 0.04),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // ── Visual mini resume preview ──
                        Expanded(
                          child: _TemplateThumbnail(template: template),
                        ),
                        // ── Label row ──
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark.withValues(alpha: 0.9),
                            border: Border(
                              top: BorderSide(
                                color: selected
                                    ? AppColors.appBlue.withValues(alpha: 0.4)
                                    : AppColors.whiteColor.withValues(alpha: 0.06),
                              ),
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      template.label,
                                      style: AppStyle.style14w700(color: AppColors.whiteColor),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      template.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppStyle.style11w400(
                                        color: AppColors.whiteColor.withValues(alpha: 0.65),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 150),
                                child: Icon(
                                  selected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  key: ValueKey<bool>(selected),
                                  color: selected
                                      ? AppColors.appGreenC
                                      : AppColors.whiteColor.withValues(alpha: 0.4),
                                  size: 22.r,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  // ── Step 2 – Editor ──────────────────────────────────────────────────────────

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

  // ── Step 3 – Preview & Download ──────────────────────────────────────────────

  Widget _buildPreviewStep(ResumeDraft? draft, List<String> issues) {
    if (draft == null) {
      return _lockedStep('Upload, select a template, and edit your resume before previewing.');
    }

    return Column(
      key: const ValueKey<int>(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── Action card ──
        AppGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Preview your resume',
                style: AppStyle.style20w700(color: AppColors.whiteColor),
              ),
              SizedBox(height: 6.h),
              Text(
                issues.isEmpty
                    ? 'Everything looks ready — save, share or download below.'
                    : 'Completing the missing fields will improve the result.',
                style: AppStyle.style13w400(
                  color: AppColors.whiteColor.withValues(alpha: 0.72),
                ),
              ),
              SizedBox(height: 14.h),
              // ── 3 action buttons ──
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: <Widget>[
                  // Save to My CVs
                  _ActionButton(
                    icon: _isSaving ? Icons.hourglass_top_rounded : Icons.save_rounded,
                    label: _isSaving ? 'Saving…' : 'Save to My CVs',
                    gradient: const LinearGradient(
                      colors: <Color>[AppColors.appGreenC, AppColors.appDarkGreenC],
                    ),
                    onTap: _isSaving
                        ? null
                        : () async {
                            setState(() => _isSaving = true);
                            final bool ok = await _controller.saveDraftExplicitly();
                            if (mounted) {
                              setState(() => _isSaving = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: <Widget>[
                                      Icon(
                                        ok ? Icons.check_circle_rounded : Icons.error_rounded,
                                        color: AppColors.whiteColor,
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        ok
                                            ? '✅ Resume saved to My CVs!'
                                            : '❌ Could not save resume.',
                                      ),
                                    ],
                                  ),
                                  backgroundColor: ok ? AppColors.appGreenC : AppColors.appPink,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  margin: EdgeInsets.all(16.r),
                                ),
                              );
                            }
                          },
                  ),

                  // Share PDF
                  _ActionButton(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    gradient: const LinearGradient(
                      colors: <Color>[AppColors.appBlue, AppColors.appPurple],
                    ),
                    onTap: () async {
                      final Uint8List bytes = await _controller.buildPdf();
                      final String fileName =
                          '${draft.displayName.replaceAll(' ', '_')}.pdf';
                      await Printing.sharePdf(bytes: bytes, filename: fileName);
                    },
                  ),

                  // Download / Print
                  _ActionButton(
                    icon: Icons.download_rounded,
                    label: 'Download PDF',
                    gradient: const LinearGradient(
                      colors: <Color>[AppColors.appPink, AppColors.appOrangeC],
                    ),
                    onTap: () async {
                      final Uint8List bytes = await _controller.buildPdf();
                      final String fileName =
                          '${draft.displayName.replaceAll(' ', '_')}.pdf';
                      await Printing.sharePdf(bytes: bytes, filename: fileName);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        // ── PDF preview ──
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

  // ── Sub-section builders ─────────────────────────────────────────────────────

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
                      padding: EdgeInsets.only(
                          bottom: index == draft.resume.experience.length - 1 ? 0 : 16.h),
                      child: _entryCard(
                        title: 'Experience ${index + 1}',
                        onRemove: () =>
                            _markDirty(() => _controller.removeExperience(index)),
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
                      padding: EdgeInsets.only(
                          bottom: index == draft.resume.education.length - 1 ? 0 : 16.h),
                      child: _entryCard(
                        title: 'Education ${index + 1}',
                        onRemove: () =>
                            _markDirty(() => _controller.removeEducation(index)),
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
                      padding: EdgeInsets.only(
                          bottom: index == draft.resume.projects.length - 1 ? 0 : 16.h),
                      child: _entryCard(
                        title: 'Project ${index + 1}',
                        onRemove: () =>
                            _markDirty(() => _controller.removeProject(index)),
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

  // ── Utility widgets ─────────────────────────────────────────────────────────

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

  // ── Footer ───────────────────────────────────────────────────────────────────

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
}

// ── Visual Template Thumbnail ────────────────────────────────────────────────

class _TemplateThumbnail extends StatelessWidget {
  const _TemplateThumbnail({required this.template});
  final ResumeTemplate template;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ResumePainter(template: template),
    );
  }
}

class _ResumePainter extends CustomPainter {
  const _ResumePainter({required this.template});
  final ResumeTemplate template;

  @override
  void paint(Canvas canvas, Size size) {
    switch (template) {
      case ResumeTemplate.modern:
        _paintModern(canvas, size);
        break;
      case ResumeTemplate.classic:
        _paintClassic(canvas, size);
        break;
      case ResumeTemplate.minimal:
        _paintMinimal(canvas, size);
        break;
      case ResumeTemplate.creative:
        _paintCreative(canvas, size);
        break;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _bg(Canvas canvas, Size size, Color color) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = color);
  }

  void _rect(Canvas canvas, double x, double y, double w, double h, Color color,
      {double radius = 2}) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(radius)),
      Paint()..color = color,
    );
  }

  void _line(Canvas canvas, double x, double y, double w, Color color,
      {double h = 3}) {
    _rect(canvas, x, y, w, h, color, radius: 1.5);
  }

  // ── Modern ───────────────────────────────────────────────────────────────────

  void _paintModern(Canvas canvas, Size size) {
    const Color accent = Color(0xFF5B6CFF);
    const Color bg = Color(0xFF0F1629);
    const Color dimText = Color(0xFF64748B);

    _bg(canvas, size, bg);

    // Header band
    _rect(canvas, 0, 0, size.width, size.height * 0.28, accent);

    // Avatar circle
    final double cx = 24;
    final double cy = size.height * 0.14;
    canvas.drawCircle(
        Offset(cx, cy), 16, Paint()..color = Colors.white.withValues(alpha: 0.25));

    // Name bar
    _rect(canvas, 46, cy - 7, size.width * 0.45, 8, Colors.white.withValues(alpha: 0.9),
        radius: 2);
    // Subtitle bar
    _rect(canvas, 46, cy + 5, size.width * 0.32, 5,
        Colors.white.withValues(alpha: 0.5),
        radius: 1.5);

    // Section: Experience
    double y = size.height * 0.33;
    _rect(canvas, 12, y, 36, 5, accent, radius: 1.5);
    y += 12;
    _line(canvas, 12, y, size.width - 24, dimText);
    y += 8;
    _line(canvas, 12, y, size.width * 0.6, dimText);
    y += 8;
    _line(canvas, 12, y, size.width * 0.5, dimText);

    // Section: Education
    y += 14;
    _rect(canvas, 12, y, 50, 5, accent, radius: 1.5);
    y += 12;
    _line(canvas, 12, y, size.width - 24, dimText);
    y += 8;
    _line(canvas, 12, y, size.width * 0.5, dimText);

    // Skills chips
    y += 14;
    _rect(canvas, 12, y, 40, 5, accent, radius: 1.5);
    y += 12;
    double cx2 = 12;
    for (int i = 0; i < 3; i++) {
      final double w = 30.0 + i * 8;
      _rect(canvas, cx2, y, w, 9, accent.withValues(alpha: 0.3), radius: 4);
      cx2 += w + 6;
    }
  }

  // ── Classic ──────────────────────────────────────────────────────────────────

  void _paintClassic(Canvas canvas, Size size) {
    const Color accent = Color(0xFF1E293B);
    const Color bg = Color(0xFFF8FAFC);
    const Color dimText = Color(0xFF94A3B8);
    const Color lineColor = Color(0xFFCBD5E1);

    _bg(canvas, size, bg);

    // Top border line
    _rect(canvas, 0, 0, size.width, 4, accent);

    // Name large
    _rect(canvas, 12, 14, size.width * 0.55, 10, accent, radius: 2);
    // Subtitle
    _rect(canvas, 12, 28, size.width * 0.38, 6, dimText, radius: 1.5);

    // Divider
    _line(canvas, 12, 42, size.width - 24, lineColor, h: 1);

    // Two columns
    final double col1w = size.width * 0.38;
    final double col2x = col1w + 18;
    final double col2w = size.width - col2x - 12;

    double y = 52;

    // Left column: Contact
    _rect(canvas, 12, y, 28, 5, accent, radius: 1);
    y += 10;
    _line(canvas, 12, y, col1w - 8, dimText);
    y += 7;
    _line(canvas, 12, y, col1w - 14, dimText);
    y += 7;
    _line(canvas, 12, y, col1w - 10, dimText);

    // Right column: Experience
    double ry = 52;
    _rect(canvas, col2x, ry, 40, 5, accent, radius: 1);
    ry += 10;
    _line(canvas, col2x, ry, col2w, dimText);
    ry += 7;
    _line(canvas, col2x, ry, col2w * 0.8, dimText);
    ry += 7;
    _line(canvas, col2x, ry, col2w * 0.7, dimText);
    ry += 14;
    _line(canvas, col2x, ry, col2w, dimText);
    ry += 7;
    _line(canvas, col2x, ry, col2w * 0.6, dimText);

    // Left: Skills
    y += 20;
    _rect(canvas, 12, y, 26, 5, accent, radius: 1);
    y += 10;
    for (int i = 0; i < 4; i++) {
      _rect(canvas, 12, y, col1w - 8, 5, lineColor, radius: 1);
      y += 8;
    }
  }

  // ── Minimal ──────────────────────────────────────────────────────────────────

  void _paintMinimal(Canvas canvas, Size size) {
    const Color accent = Color(0xFF64748B);
    const Color bg = Color(0xFFFFFFFF);
    const Color dimText = Color(0xFFCBD5E1);

    _bg(canvas, size, bg);

    // Name
    _rect(canvas, 16, 16, size.width * 0.5, 9, const Color(0xFF1E293B), radius: 2);
    // Title
    _rect(canvas, 16, 29, size.width * 0.35, 5, accent, radius: 1.5);

    // Thin bottom-border under header
    _line(canvas, 16, 40, size.width - 32, accent.withValues(alpha: 0.3), h: 1);

    double y = 52;
    // Summary section
    _line(canvas, 16, y, size.width - 32, dimText);
    y += 7;
    _line(canvas, 16, y, size.width * 0.75, dimText);
    y += 7;
    _line(canvas, 16, y, size.width * 0.6, dimText);

    y += 14;
    // Section label
    _rect(canvas, 16, y, 40, 4, accent, radius: 1);
    _line(canvas, 60, y + 1.5, size.width - 76, dimText, h: 1);
    y += 10;
    _line(canvas, 16, y, size.width - 32, dimText);
    y += 7;
    _line(canvas, 16, y, size.width * 0.65, dimText);

    y += 14;
    _rect(canvas, 16, y, 45, 4, accent, radius: 1);
    _line(canvas, 65, y + 1.5, size.width - 81, dimText, h: 1);
    y += 10;
    _line(canvas, 16, y, size.width - 32, dimText);
    y += 7;
    _line(canvas, 16, y, size.width * 0.5, dimText);

    y += 14;
    _rect(canvas, 16, y, 30, 4, accent, radius: 1);
    _line(canvas, 50, y + 1.5, size.width - 66, dimText, h: 1);
    y += 10;
    double cx2 = 16;
    for (int i = 0; i < 4; i++) {
      final double w = 28.0 + i * 4;
      _rect(canvas, cx2, y, w, 8, dimText, radius: 4);
      cx2 += w + 5;
      if (cx2 > size.width - 30) break;
    }
  }

  // ── Creative ─────────────────────────────────────────────────────────────────

  void _paintCreative(Canvas canvas, Size size) {
    const Color accent1 = Color(0xFFD946EF);
    const Color accent2 = Color(0xFFF97316);
    const Color bg = Color(0xFF0F172A);
    const Color dimText = Color(0xFF64748B);

    _bg(canvas, size, bg);

    // Left sidebar gradient strip
    final Rect sideRect = Rect.fromLTWH(0, 0, size.width * 0.3, size.height);
    final Paint sidePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[accent1, accent2],
      ).createShader(sideRect);
    canvas.drawRect(sideRect, sidePaint);

    // Avatar circle on sidebar
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.16),
      20,
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );

    // Sidebar labels
    double sy = size.height * 0.34;
    final double sw = size.width * 0.24;
    for (int i = 0; i < 5; i++) {
      _line(canvas, 8, sy, sw, Colors.white.withValues(alpha: 0.5 - i * 0.06));
      sy += 9;
    }

    // Main area content
    final double mx = size.width * 0.34;
    final double mw = size.width - mx - 10;

    double y = 16;
    // Name
    _rect(canvas, mx, y, mw * 0.7, 9, Colors.white.withValues(alpha: 0.88), radius: 2);
    y += 13;
    _rect(canvas, mx, y, mw * 0.5, 5, accent1.withValues(alpha: 0.7), radius: 1.5);

    y += 16;
    // Experience heading
    _rect(canvas, mx, y, 40, 5, accent2, radius: 1.5);
    y += 11;
    _line(canvas, mx, y, mw, dimText);
    y += 7;
    _line(canvas, mx, y, mw * 0.75, dimText);
    y += 7;
    _line(canvas, mx, y, mw * 0.6, dimText);

    y += 14;
    _rect(canvas, mx, y, 38, 5, accent2, radius: 1.5);
    y += 11;
    _line(canvas, mx, y, mw, dimText);
    y += 7;
    _line(canvas, mx, y, mw * 0.7, dimText);

    y += 14;
    _rect(canvas, mx, y, 30, 5, accent2, radius: 1.5);
    y += 11;
    double cx2 = mx;
    for (int i = 0; i < 3; i++) {
      final double w = 26.0 + i * 5;
      _rect(canvas, cx2, y, w, 8, accent1.withValues(alpha: 0.3), radius: 4);
      cx2 += w + 5;
      if (cx2 > size.width - 10) break;
    }
  }

  @override
  bool shouldRepaint(_ResumePainter oldDelegate) =>
      oldDelegate.template != template;
}

// ── Action Button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: Colors.white, size: 18.r),
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppStyle.style13w600(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
