import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({
    super.key,
    required this.onUpload,
    required this.onOpenCamera,
    required this.onCreateAccount,
  });

  final VoidCallback onUpload;
  final VoidCallback onOpenCamera;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Documents',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload your Aadhaar and take a selfie',
            style: TextStyle(color: AppColors.mutedText, fontSize: 14),
          ),
          const SizedBox(height: 28),

          _UploadCard(onUpload: onUpload),
          const SizedBox(height: 20),
          _SelfieCard(onOpenCamera: onOpenCamera),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({required this.onUpload});

  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Text(
            'Aadhaar card photo',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Clear photo of the front side.',
            style: TextStyle(color: AppColors.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_outlined),
            label: const Text('Upload Aadhaar photo'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              foregroundColor: AppColors.navy,
              side: const BorderSide(
                color: AppColors.border,
                style: BorderStyle.solid,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelfieCard extends StatelessWidget {
  const _SelfieCard({required this.onOpenCamera});

  final VoidCallback onOpenCamera;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.softBlue,
            child: Icon(
              Icons.camera_alt_outlined,
              color: AppColors.mutedText,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live selfie verification',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Take a photo. It is matched with your Aadhaar photo.',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: onOpenCamera,
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Open camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
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