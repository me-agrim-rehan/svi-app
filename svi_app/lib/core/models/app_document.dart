// lib/core/models/app_document.dart


class AppDocument {
  final String id;
  final String name;
  final String url;
  final String documentType;
  final DateTime? uploadedAt;

  AppDocument({
    required this.id,
    required this.name,
    required this.url,
    required this.documentType,
    required this.uploadedAt,
  });

  factory AppDocument.fromJson(Map<String, dynamic> json) {
    return AppDocument(
      id: json['id']?.toString() ?? '',
      name: json['document_name']?.toString() ?? 'Document',
      url: json['file_url']?.toString() ?? '',
      documentType: json['document_type']?.toString() ?? 'other',
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(
              json['uploaded_at'].toString(),
            )
          : null,
    );
  }
}