import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/app_document.dart';
import '../../../../services/docs_service.dart';

class DocsPage extends StatefulWidget {
  const DocsPage({super.key, required this.phone});

  final String phone;

  @override
  State<DocsPage> createState() => _DocsPageState();
}

class _DocsPageState extends State<DocsPage> {
  final DocsService _docsService = DocsService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoadingDocs = true;
  List<AppDocument> _documents = [];

  Uint8List? _certificateBytes;
  bool _isUploadingCertificate = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoadingDocs = true);

    final docs = await _docsService.fetchDocuments(phone: widget.phone);

    if (!mounted) return;

    setState(() {
      _documents = docs;
      _isLoadingDocs = false;
    });
  }

  Future<void> _openDocument(AppDocument doc) async {
    if (doc.url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This document isn't available yet.")),
      );
      return;
    }

    final uri = Uri.parse(doc.url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open this document.")),
      );
    }
  }

  Future<void> _pickCertificatePhoto() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      _certificateBytes = bytes;
      _isUploadingCertificate = true;
    });

    final success = await _docsService.uploadSignedCertificate(
      phone: widget.phone,
      photo: picked,
    );

    if (!mounted) return;

    setState(() => _isUploadingCertificate = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Signed certificate uploaded.'
              : 'Failed to upload. Please try again.',
        ),
      ),
    );
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
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Offer letters and other files sent to you',
            style: TextStyle(color: AppColors.mutedText, fontSize: 13),
          ),
          const SizedBox(height: 16),

          if (_isLoadingDocs)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
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
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 24),

          const Text(
            'Signed certificate',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Upload a photo of your signed certificate',
            style: TextStyle(color: AppColors.mutedText, fontSize: 13),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_certificateBytes != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      _certificateBytes!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: _isUploadingCertificate ? null : _pickCertificatePhoto,
                  icon: _isUploadingCertificate
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_outlined),
                  label: Text(
                    _certificateBytes == null
                        ? 'Upload signed certificate photo'
                        : 'Change photo',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.border),
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
  const _DocumentCard({required this.document, required this.onDownload});

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
        border: Border.all(color: AppColors.border),
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
            child: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.navy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              document.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onDownload,
            icon: const Icon(Icons.download_outlined, color: AppColors.navy),
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
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Text(
          'No documents yet.',
          style: TextStyle(color: AppColors.mutedText, fontSize: 13),
        ),
      ),
    );
  }
}