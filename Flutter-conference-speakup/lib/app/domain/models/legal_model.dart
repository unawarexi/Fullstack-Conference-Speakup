/// A single section within a legal document (ToS or Privacy Policy).
class LegalSection {
  final String id;
  final String heading;
  final String body;
  final List<String> items;
  final String? footer;
  final List<LegalSubsection> subsections;

  const LegalSection({
    required this.id,
    required this.heading,
    required this.body,
    this.items = const [],
    this.footer,
    this.subsections = const [],
  });

  factory LegalSection.fromJson(Map<String, dynamic> json) => LegalSection(
        id: json['id'] as String,
        heading: json['heading'] as String,
        body: json['body'] as String,
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        footer: json['footer'] as String?,
        subsections: (json['subsections'] as List<dynamic>?)
                ?.map((e) => LegalSubsection.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

/// A subsection within a legal section (e.g., 2.1, 2.2).
class LegalSubsection {
  final String heading;
  final List<String> items;

  const LegalSubsection({required this.heading, this.items = const []});

  factory LegalSubsection.fromJson(Map<String, dynamic> json) =>
      LegalSubsection(
        heading: json['heading'] as String,
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );
}

/// A complete legal document (Terms of Service or Privacy Policy).
class LegalDocument {
  final String title;
  final String effectiveDate;
  final String lastUpdated;
  final String version;
  final List<LegalSection> sections;

  const LegalDocument({
    required this.title,
    required this.effectiveDate,
    required this.lastUpdated,
    required this.version,
    required this.sections,
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) => LegalDocument(
        title: json['title'] as String,
        effectiveDate: json['effectiveDate'] as String,
        lastUpdated: json['lastUpdated'] as String,
        version: json['version'] as String,
        sections: (json['sections'] as List<dynamic>)
            .map((e) => LegalSection.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
