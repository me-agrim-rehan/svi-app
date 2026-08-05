import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/registration_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature will be connected later.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.construction_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Verified registration takes about two minutes',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 36),

                const RegistrationTextField(label: 'Full name'),

                Row(
                  children: [
                    const Expanded(
                      child: RegistrationTextField(
                        label: 'Phone number',
                        hintText: '+91 00000 00000',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 27),
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _showComingSoon(context, 'OTP sending'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.softBlue,
                            foregroundColor: AppColors.navy,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Send OTP'),
                        ),
                      ),
                    ),
                  ],
                ),

                const RegistrationTextField(
                  label: 'Enter OTP',
                  hintText: '0  0  0  0  0  0',
                  keyboardType: TextInputType.number,
                ),
                const RegistrationTextField(label: 'Address'),

                const Row(
                  children: [
                    Expanded(
                      child: RegistrationTextField(
                        label: 'City',
                        hintText: 'Pune',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: RegistrationTextField(
                        label: 'State',
                        hintText: 'Maharashtra',
                      ),
                    ),
                  ],
                ),

                const RegistrationTextField(
                  label: 'Occupation',
                  hintText: 'Mason, driver, security guard...',
                ),
                const RegistrationTextField(
                  label: 'Description (optional)',
                  hintText: 'Years of experience, tools you own, shifts you prefer...',
                  maxLines: 3,
                ),
                const RegistrationTextField(
                  label: 'Aadhaar number',
                  hintText: '0000 0000 0000',
                  keyboardType: TextInputType.number,
                ),

                _UploadCard(
                  onUpload: () => _showComingSoon(context, 'Photo upload'),
                ),
                const SizedBox(height: 20),
                _SelfieCard(
                  onOpenCamera: () =>
                      _showComingSoon(context, 'Camera verification'),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () =>
                        _showComingSoon(context, 'Account creation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Create account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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