class ResumeModel {
  ResumeModel({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.jobTitle = '',
    this.summary = '',
    List<Experience>? experience,
    List<Education>? education,
    List<String>? skills,
    List<String>? languages,
    List<Project>? projects,
  }) : experience = experience ?? <Experience>[],
       education = education ?? <Education>[],
       skills = skills ?? <String>[],
       languages = languages ?? <String>[],
       projects = projects ?? <Project>[];

  String name;
  String email;
  String phone;
  String location;
  String jobTitle;
  String summary;
  List<Experience> experience;
  List<Education> education;
  List<String> skills;
  List<String> languages;
  List<Project> projects;

  factory ResumeModel.empty() => ResumeModel(
    experience: <Experience>[],
    education: <Education>[],
    projects: <Project>[],
  );

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      jobTitle: json['jobTitle']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      skills: _stringList(json['skills']),
      languages: _stringList(json['languages']),
      experience: (json['experience'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => Experience.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      education: (json['education'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => Education.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      projects: (json['projects'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => Project.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'jobTitle': jobTitle,
      'summary': summary,
      'skills': skills,
      'languages': languages,
      'experience': experience.map((Experience item) => item.toJson()).toList(),
      'education': education.map((Education item) => item.toJson()).toList(),
      'projects': projects.map((Project item) => item.toJson()).toList(),
    };
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((dynamic item) => item.toString().trim())
          .where((String item) => item.isNotEmpty)
          .toList();
    }
    return <String>[];
  }
}

class Experience {
  Experience({
    this.title = '',
    this.company = '',
    this.duration = '',
    this.description = '',
  });

  String title;
  String company;
  String duration;
  String description;

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      title: json['title']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'company': company,
      'duration': duration,
      'description': description,
    };
  }
}

class Education {
  Education({
    this.degree = '',
    this.institution = '',
    this.year = '',
  });

  String degree;
  String institution;
  String year;

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      degree: json['degree']?.toString() ?? '',
      institution: json['institution']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'degree': degree,
      'institution': institution,
      'year': year,
    };
  }
}

class Project {
  Project({
    this.name = '',
    this.description = '',
    this.tech = '',
  });

  String name;
  String description;
  String tech;

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      tech: json['tech']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'tech': tech,
    };
  }
}

enum ResumeTemplate { modern, classic, minimal, creative }

extension ResumeTemplateX on ResumeTemplate {
  String get label {
    switch (this) {
      case ResumeTemplate.modern:
        return 'Modern';
      case ResumeTemplate.classic:
        return 'Classic';
      case ResumeTemplate.minimal:
        return 'Minimal';
      case ResumeTemplate.creative:
        return 'Creative';
    }
  }

  String get description {
    switch (this) {
      case ResumeTemplate.modern:
        return 'Bold headings with a clean recruiter-friendly layout.';
      case ResumeTemplate.classic:
        return 'Traditional structure that works for most roles.';
      case ResumeTemplate.minimal:
        return 'Simple, airy design with focus on content.';
      case ResumeTemplate.creative:
        return 'Accent-driven look for design and marketing profiles.';
    }
  }
}

class ResumeDraft {
  ResumeDraft({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.originalFileName,
    required this.originalPdfBytes,
    required this.resume,
    this.template = ResumeTemplate.modern,
    this.aiEnhanced = false,
  });

  final String id;
  final DateTime createdAt;
  DateTime updatedAt;
  String originalFileName;
  List<int> originalPdfBytes;
  ResumeModel resume;
  ResumeTemplate template;
  bool aiEnhanced;

  String get displayName {
    if (resume.name.trim().isNotEmpty) {
      return resume.name.trim();
    }
    return originalFileName.replaceAll('.pdf', '');
  }
}
