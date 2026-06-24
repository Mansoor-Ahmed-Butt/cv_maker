import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:flutter_with_hive/view/resume_workflow/resume_models.dart';

class ResumePdfService {
  Future<Uint8List> generateResume(
    ResumeModel resume,
    ResumeTemplate template,
  ) async {
    final pw.Document pdf = pw.Document();
    final pw.Font baseFont = await PdfGoogleFonts.nunitoRegular();
    final pw.Font boldFont = await PdfGoogleFonts.nunitoBold();
    final PdfColor accent = _accentColor(template);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(28),
          theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
        ),
        build: (pw.Context context) {
          return <pw.Widget>[
            _buildHeader(resume, template, accent),
            _buildSection(
              title: 'Professional Summary',
              child: pw.Text(
                resume.summary.trim().isEmpty ? 'Add a short professional summary.' : resume.summary,
              ),
              accent: accent,
            ),
            _buildExperienceSection(resume, accent),
            _buildEducationSection(resume, accent),
            _buildSkillsSection(resume, accent),
            _buildProjectsSection(resume, accent),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(
    ResumeModel resume,
    ResumeTemplate template,
    PdfColor accent,
  ) {
    final String subtitle = <String>[
      resume.jobTitle,
      resume.location,
      resume.email,
      resume.phone,
    ].where((String value) => value.trim().isNotEmpty).join('  |  ');

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 14),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: accent, width: template == ResumeTemplate.minimal ? 1 : 2),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            resume.name.trim().isEmpty ? 'Your Name' : resume.name,
            style: pw.TextStyle(
              fontSize: template == ResumeTemplate.creative ? 30 : 26,
              fontWeight: pw.FontWeight.bold,
              color: template == ResumeTemplate.classic ? PdfColors.black : accent,
            ),
          ),
          if (subtitle.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 6),
            pw.Text(
              subtitle,
              style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildSection({
    required String title,
    required pw.Widget child,
    required PdfColor accent,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: accent,
            ),
          ),
          pw.SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  pw.Widget _buildExperienceSection(ResumeModel resume, PdfColor accent) {
    if (resume.experience.isEmpty) {
      return _buildSection(
        title: 'Experience',
        child: pw.Text('Add at least one work experience entry.'),
        accent: accent,
      );
    }

    return _buildSection(
      title: 'Experience',
      accent: accent,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: resume.experience.map((Experience item) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  '${item.title.isEmpty ? 'Role Title' : item.title} - '
                  '${item.company.isEmpty ? 'Company' : item.company}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                if (item.duration.trim().isNotEmpty)
                  pw.Text(
                    item.duration,
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                if (item.description.trim().isNotEmpty) pw.SizedBox(height: 4),
                if (item.description.trim().isNotEmpty) pw.Text(item.description),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _buildEducationSection(ResumeModel resume, PdfColor accent) {
    if (resume.education.isEmpty) {
      return _buildSection(
        title: 'Education',
        child: pw.Text('Add at least one education entry.'),
        accent: accent,
      );
    }

    return _buildSection(
      title: 'Education',
      accent: accent,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: resume.education.map((Education item) {
          final String line = <String>[
            item.degree,
            item.institution,
            item.year,
          ].where((String value) => value.trim().isNotEmpty).join('  |  ');
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Text(line.isEmpty ? 'Degree | Institution | Year' : line),
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _buildSkillsSection(ResumeModel resume, PdfColor accent) {
    final List<String> skills = <String>[
      ...resume.skills,
      ...resume.languages.map((String value) => 'Language: $value'),
    ].where((String value) => value.trim().isNotEmpty).toList();

    return _buildSection(
      title: 'Skills',
      accent: accent,
      child: pw.Wrap(
        spacing: 6,
        runSpacing: 6,
        children: skills.isEmpty
            ? <pw.Widget>[pw.Text('Add some skills to strengthen the resume.')]
            : skills.map((String skill) {
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: pw.BoxDecoration(
                    color: accent.shade(0.12),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Text(skill, style: const pw.TextStyle(fontSize: 10)),
                );
              }).toList(),
      ),
    );
  }

  pw.Widget _buildProjectsSection(ResumeModel resume, PdfColor accent) {
    if (resume.projects.isEmpty) {
      return _buildSection(
        title: 'Projects',
        child: pw.Text('Add optional projects to showcase work samples.'),
        accent: accent,
      );
    }

    return _buildSection(
      title: 'Projects',
      accent: accent,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: resume.projects.map((Project item) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  item.name.trim().isEmpty ? 'Project Name' : item.name,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                if (item.tech.trim().isNotEmpty)
                  pw.Text(
                    item.tech,
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                if (item.description.trim().isNotEmpty) pw.SizedBox(height: 4),
                if (item.description.trim().isNotEmpty) pw.Text(item.description),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  PdfColor _accentColor(ResumeTemplate template) {
    switch (template) {
      case ResumeTemplate.modern:
        return PdfColor.fromHex('#5B6CFF');
      case ResumeTemplate.classic:
        return PdfColor.fromHex('#1E293B');
      case ResumeTemplate.minimal:
        return PdfColor.fromHex('#64748B');
      case ResumeTemplate.creative:
        return PdfColor.fromHex('#D946EF');
    }
  }
}
