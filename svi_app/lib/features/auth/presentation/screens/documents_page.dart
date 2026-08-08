// lib/features/auth/presentation/screens/documents_page.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({
    super.key,
    required this.onAadhaarImagePicked,
    required this.onSelfieImagePicked,
    required this.onCreateAccount,
  });

  final ValueChanged<XFile?> onAadhaarImagePicked;
  final ValueChanged<XFile?> onSelfieImagePicked;
  final VoidCallback onCreateAccount;

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final ImagePicker _picker = ImagePicker();

  XFile? _aadhaarFile;
  XFile? _selfieFile;
  Uint8List? _aadhaarBytes;
  Uint8List? _selfieBytes;

  Future<void> _pickAadhaarImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _aadhaarFile = picked;
      _aadhaarBytes = bytes;
    });
    widget.onAadhaarImagePicked(picked);
  }

  Future<void> _openCameraForSelfie() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _selfieFile = picked;
      _selfieBytes = bytes;
    });
    widget.onSelfieImagePicked(picked);
  }

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

          _UploadCard(
            onUpload: _pickAadhaarImage,
            imageBytes: _aadhaarBytes,
            hasImage: _aadhaarFile != null,
          ),
          const SizedBox(height: 20),
          _SelfieCard(
            onOpenCamera: _openCameraForSelfie,
            imageBytes: _selfieBytes,
            hasImage: _selfieFile != null,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.onUpload,
    this.imageBytes,
    this.hasImage = false,
  });

  final VoidCallback onUpload;
  final Uint8List? imageBytes;
  final bool hasImage;

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
          if (imageBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                imageBytes!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
          ],
          OutlinedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_outlined),
            label: Text(hasImage ? 'Change photo' : 'Upload Aadhaar photo'),
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
  const _SelfieCard({
    required this.onOpenCamera,
    this.imageBytes,
    this.hasImage = false,
  });

  final VoidCallback onOpenCamera;
  final Uint8List? imageBytes;
  final bool hasImage;

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
          CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.softBlue,
            backgroundImage: imageBytes != null ? MemoryImage(imageBytes!) : null,
            child: imageBytes == null
                ? const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.mutedText,
                    size: 30,
                  )
                : null,
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
                    label: Text(hasImage ? 'Retake' : 'Open camera'),
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