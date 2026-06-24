import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import 'package:flutter_with_hive/view/resume_workflow/resume_ai_service.dart';
import 'package:flutter_with_hive/view/resume_workflow/resume_models.dart';
import 'package:flutter_with_hive/view/resume_workflow/resume_pdf_service.dart';

class ResumeWorkspaceController extends GetxController {
  ResumeWorkspaceController({
    required ResumeAiService aiService,
    required ResumePdfService pdfService,
  }) : _aiService = aiService,
       _pdfService = pdfService;

  final ResumeAiService _aiService;
  final ResumePdfService _pdfService;

  final RxList<ResumeDraft> drafts = <ResumeDraft>[].obs;
  final Rxn<ResumeDraft> currentDraft = Rxn<ResumeDraft>();
  final RxBool isParsing = false.obs;
  final RxString statusMessage = ''.obs;
  final Rx<ResumeTemplate> preferredTemplate = ResumeTemplate.modern.obs;

  bool get hasGeminiConfigured => _aiService.isConfigured;

  Future<bool> importOldCv() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return false;
    }

    final PlatformFile file = result.files.single;
    final Uint8List? bytes = await _resolveBytes(file);
    if (bytes == null) {
      statusMessage.value = 'Unable to read the selected PDF file.';
      return false;
    }

    isParsing.value = true;
    statusMessage.value = hasGeminiConfigured
        ? 'Uploading and analyzing your existing CV with Gemini...'
        : 'CV uploaded. Gemini key not configured, so a draft shell was created for manual completion.';

    try {
      final ResumeModel parsedResume = await _aiService.parseResume(
        pdfBytes: bytes,
        fileName: file.name,
      );

      final DateTime now = DateTime.now();
      final ResumeDraft draft = ResumeDraft(
        id: now.microsecondsSinceEpoch.toString(),
        createdAt: now,
        updatedAt: now,
        originalFileName: file.name,
        originalPdfBytes: bytes,
        resume: parsedResume,
        template: preferredTemplate.value,
        aiEnhanced: hasGeminiConfigured,
      );

      currentDraft.value = draft;
      drafts.insert(0, draft);
      statusMessage.value = 'CV imported. Select a new template and complete any missing fields.';
      return true;
    } catch (_) {
      statusMessage.value = 'We could not parse that CV. Please try another PDF.';
      return false;
    } finally {
      isParsing.value = false;
    }
  }

  Future<Uint8List?> _resolveBytes(PlatformFile file) async {
    if (file.bytes != null) {
      return file.bytes!;
    }

    return null;
  }

  void startFresh() {
    currentDraft.value = null;
    statusMessage.value = '';
  }

  void openDraft(String draftId) {
    try {
      currentDraft.value = drafts.firstWhere((ResumeDraft item) => item.id == draftId);
      statusMessage.value = 'Resume loaded. Continue editing or preview the latest version.';
    } catch (_) {
      statusMessage.value = 'Selected resume could not be found.';
    }
  }

  void deleteDraft(String draftId) {
    drafts.removeWhere((ResumeDraft item) => item.id == draftId);
    if (currentDraft.value?.id == draftId) {
      currentDraft.value = null;
    }
  }

  void selectTemplate(ResumeTemplate template) {
    preferredTemplate.value = template;
    final ResumeDraft? draft = currentDraft.value;
    if (draft == null) {
      return;
    }
    draft.template = template;
    _touchDraft();
  }

  void updatePersonalInfo({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? jobTitle,
    String? summary,
  }) {
    final ResumeDraft? draft = currentDraft.value;
    if (draft == null) {
      return;
    }

    if (name != null) {
      draft.resume.name = name;
    }
    if (email != null) {
      draft.resume.email = email;
    }
    if (phone != null) {
      draft.resume.phone = phone;
    }
    if (location != null) {
      draft.resume.location = location;
    }
    if (jobTitle != null) {
      draft.resume.jobTitle = jobTitle;
    }
    if (summary != null) {
      draft.resume.summary = summary;
    }
    _touchDraft(shouldRefresh: false);
  }

  void updateSkills(String value) {
    final ResumeDraft? draft = currentDraft.value;
    if (draft == null) {
      return;
    }
    draft.resume.skills = _splitCommaSeparated(value);
    _touchDraft(shouldRefresh: false);
  }

  void updateLanguages(String value) {
    final ResumeDraft? draft = currentDraft.value;
    if (draft == null) {
      return;
    }
    draft.resume.languages = _splitCommaSeparated(value);
    _touchDraft(shouldRefresh: false);
  }

  void addExperience() {
    currentDraft.value?.resume.experience.add(Experience());
    _touchDraft();
  }

  void removeExperience(int index) {
    final List<Experience>? items = currentDraft.value?.resume.experience;
    if (items == null || index < 0 || index >= items.length) {
      return;
    }
    items.removeAt(index);
    _touchDraft();
  }

  void updateExperience(
    int index, {
    String? title,
    String? company,
    String? duration,
    String? description,
  }) {
    final List<Experience>? items = currentDraft.value?.resume.experience;
    if (items == null || index < 0 || index >= items.length) {
      return;
    }
    final Experience item = items[index];
    if (title != null) {
      item.title = title;
    }
    if (company != null) {
      item.company = company;
    }
    if (duration != null) {
      item.duration = duration;
    }
    if (description != null) {
      item.description = description;
    }
    _touchDraft(shouldRefresh: false);
  }

  void addEducation() {
    currentDraft.value?.resume.education.add(Education());
    _touchDraft();
  }

  void removeEducation(int index) {
    final List<Education>? items = currentDraft.value?.resume.education;
    if (items == null || index < 0 || index >= items.length) {
      return;
    }
    items.removeAt(index);
    _touchDraft();
  }

  void updateEducation(
    int index, {
    String? degree,
    String? institution,
    String? year,
  }) {
    final List<Education>? items = currentDraft.value?.resume.education;
    if (items == null || index < 0 || index >= items.length) {
      return;
    }
    final Education item = items[index];
    if (degree != null) {
      item.degree = degree;
    }
    if (institution != null) {
      item.institution = institution;
    }
    if (year != null) {
      item.year = year;
    }
    _touchDraft(shouldRefresh: false);
  }

  void addProject() {
    currentDraft.value?.resume.projects.add(Project());
    _touchDraft();
  }

  void removeProject(int index) {
    final List<Project>? items = currentDraft.value?.resume.projects;
    if (items == null || index < 0 || index >= items.length) {
      return;
    }
    items.removeAt(index);
    _touchDraft();
  }

  void updateProject(
    int index, {
    String? name,
    String? description,
    String? tech,
  }) {
    final List<Project>? items = currentDraft.value?.resume.projects;
    if (items == null || index < 0 || index >= items.length) {
      return;
    }
    final Project item = items[index];
    if (name != null) {
      item.name = name;
    }
    if (description != null) {
      item.description = description;
    }
    if (tech != null) {
      item.tech = tech;
    }
    _touchDraft(shouldRefresh: false);
  }

  List<String> missingFields(ResumeDraft draft) {
    final List<String> issues = <String>[];
    if (draft.resume.name.trim().isEmpty) {
      issues.add('Full name is missing');
    }
    if (draft.resume.email.trim().isEmpty) {
      issues.add('Email is missing');
    }
    if (draft.resume.phone.trim().isEmpty) {
      issues.add('Phone number is missing');
    }
    if (draft.resume.jobTitle.trim().isEmpty) {
      issues.add('Target job title is missing');
    }
    if (draft.resume.summary.trim().isEmpty) {
      issues.add('Professional summary is missing');
    }
    if (draft.resume.skills.isEmpty) {
      issues.add('At least one skill is required');
    }
    if (draft.resume.experience.isEmpty) {
      issues.add('Add at least one work experience item');
    } else {
      for (int index = 0; index < draft.resume.experience.length; index++) {
        final Experience item = draft.resume.experience[index];
        if (item.title.trim().isEmpty || item.company.trim().isEmpty) {
          issues.add('Experience ${index + 1} needs a role title and company');
        }
      }
    }
    if (draft.resume.education.isEmpty) {
      issues.add('Add at least one education item');
    }
    return issues;
  }

  Future<Uint8List> buildPdf() async {
    final ResumeDraft? draft = currentDraft.value;
    if (draft == null) {
      throw StateError('No resume draft selected');
    }
    return _pdfService.generateResume(draft.resume, draft.template);
  }

  List<String> _splitCommaSeparated(String value) {
    return value
        .split(',')
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList();
  }

  void _touchDraft({bool shouldRefresh = true}) {
    final ResumeDraft? draft = currentDraft.value;
    if (draft == null) {
      return;
    }
    draft.updatedAt = DateTime.now();
    if (shouldRefresh) {
      drafts.refresh();
      currentDraft.refresh();
    }
  }
}
