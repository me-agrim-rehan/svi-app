// lib/core/models/app_document.dart

class AppDocument {
  final String id;
  final String name;
  final String url;

  AppDocument({
    required this.id,
    required this.name,
    required this.url,
  });

  // ==========================================================================
  // 🚧 DB INTEGRATION POINT 🚧
  // DB TEAM: adjust key names to match your actual API response shape.
  // ==========================================================================
  factory AppDocument.fromJson(Map<String, dynamic> json) {
    return AppDocument(
      id: json['id'].toString(),
      name: json['name'] ?? 'Document.pdf',
      url: json['url'] ?? '',
    );
  }
}