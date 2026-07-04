import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:flutter_with_hive/view/resume_workflow/resume_models.dart';

class ResumeAiService {
  ResumeAiService() {
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
    }
  }

  GenerativeModel? _model;

  bool get isConfigured => _model != null;

  Future<ResumeModel> parseResume({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    if (_model == null) {
      return _fallbackResume(fileName);
    }

    try {
      final GenerateContentResponse response = await _model!.generateContent(
        <Content>[
          Content.multi(<Part>[
            DataPart('application/pdf', pdfBytes),
            TextPart(_resumePrompt),
          ]),
        ],
      );

      final String jsonText = _normalizeJson(response.text ?? '');
      final dynamic decoded = jsonDecode(jsonText);
      if (decoded is Map<String, dynamic>) {
        return ResumeModel.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Gemini parsing failed: $e');
      // Fall back to a draft so the user can keep editing even if AI parsing fails.
    }

    return _fallbackResume(fileName);
  }

  ResumeModel _fallbackResume(String fileName) {
    final String cleanedName = fileName
        .replaceAll('.pdf', '')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();

    return ResumeModel(
      name: cleanedName,
      summary:
          'Your CV was uploaded successfully. Complete or adjust the highlighted fields before generating the final resume.',
      experience: <Experience>[Experience()],
      education: <Education>[Education()],
      projects: <Project>[Project()],
    );
  }

  String _normalizeJson(String value) {
    return value.replaceAll('```json', '').replaceAll('```', '').trim();
  }
}

const String _resumePrompt = '''
Analyze this CV/Resume PDF and extract all data.
Return ONLY a valid JSON object with this exact structure:
{
  "name": "",
  "email": "",
  "phone": "",
  "location": "",
  "jobTitle": "",
  "summary": "",
  "experience": [{"title":"","company":"","duration":"","description":""}],
  "education": [{"degree":"","institution":"","year":""}],
  "skills": [],
  "languages": [],
  "projects": [{"name":"","description":"","tech":""}]
}
''';
