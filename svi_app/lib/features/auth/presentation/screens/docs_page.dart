import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/app_document.dart';
import '../../../../services/docs_service.dart';
import '../../../../core/network/api_constants.dart';

class DocsPage extends StatefulWidget {
  const DocsPage({super.key, required this.phone});

  final String phone;

  @override
  State<DocsPage> createState() => _DocsPageState();
}

class _DocsPageState extends State<DocsPage> {
  final DocsService _docsService = DocsService();

  bool _isLoadingDocs = true;
  List<AppDocument> _documents = [];

  Uint8List? _certificateBytes;
  String? _certificateFileName;
  String? _certificateExtension;

  bool _isUploadingCertificate = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoadingDocs = true);

    final docs = await _docsService.fetchDocuments(
      phone: widget.phone,
    );

    if (!mounted) return;

    setState(() {
      _documents = docs;
      _isLoadingDocs = false;
    });
  }

  Future<void> _openDocument(AppDocument doc) async {
    if (doc.url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This document isn't available yet."),
        ),
      );
      return;
    }

    final uri = Uri.parse(
  "${ApiConstants.baseUrl}${doc.url}",
);

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't open this document."),
        ),
      );
    }
  }

  Future<void> _pickCertificateFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'png',
          'jpg',
          'jpeg',
        ],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;

      if (file.bytes == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't read the selected file."),
          ),
        );

        return;
      }

      final extension = file.extension?.toLowerCase();

      setState(() {
        _certificateBytes = file.bytes;
        _certificateFileName = file.name;
        _certificateExtension = extension;
        _isUploadingCertificate = true;
      });

      final success = await _docsService.uploadSignedCertificate(
        phone: widget.phone,
        file: file,
      );

      if (!mounted) return;

      setState(() {
        _isUploadingCertificate = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Signed certificate uploaded.'
                : 'Failed to upload. Please try again.',
          ),
        ),
      );

      if (success) {
        await _loadDocuments();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploadingCertificate = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to select/upload file: $e',
          ),
        ),
      );
    }
  }

  bool get _isCertificateImage {
    return _certificateExtension == 'png' ||
        _certificateExtension == 'jpg' ||
        _certificateExtension == 'jpeg';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        children: [
          const Text(
            'Download your documents',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Offer letters and other files sent to you',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          if (_isLoadingDocs)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_documents.isEmpty)
            _EmptyDocsCard()
          else
            ..._documents.map(
              (doc) => _DocumentCard(
                document: doc,
                onDownload: () => _openDocument(doc),
              ),
            ),

          const SizedBox(height: 28),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          const SizedBox(height: 24),

          const Text(
            'Signed certificate',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Upload your signed certificate as PDF, JPG, JPEG or PNG',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: AppColors.border,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_certificateBytes != null) ...[
                  if (_isCertificateImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        _certificateBytes!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 40,
                            color: AppColors.navy,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              _certificateFileName ?? 'PDF document',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),
                ],

                OutlinedButton.icon(
                  onPressed: _isUploadingCertificate
                      ? null
                      : _pickCertificateFile,

                  icon: _isUploadingCertificate
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.upload_outlined,
                        ),

                  label: Text(
                    _certificateBytes == null
                        ? 'Upload signed certificate'
                        : 'Change certificate',
                  ),

                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(
                      color: AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.document,
    required this.onDownload,
  });

  final AppDocument document;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.border,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.picture_as_pdf_outlined,
              color: AppColors.navy,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              document.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          IconButton(
            onPressed: onDownload,
            icon: const Icon(
              Icons.download_outlined,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDocsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.border,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Text(
          'No documents yet.',
          style: TextStyle(
            color: AppColors.mutedText,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}