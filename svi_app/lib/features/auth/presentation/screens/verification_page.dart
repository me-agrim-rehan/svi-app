import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/registration_text_field.dart';
import 'package:flutter/services.dart';

class VerificationPage extends StatelessWidget {
  const VerificationPage({
    super.key,
    required this.phoneController,
    required this.otpController,
    required this.aadhaarController,
    required this.onSendOtp,
    required this.isSendingOtp,
  });

  final TextEditingController phoneController;
  final TextEditingController otpController;
  final TextEditingController aadhaarController;
  final VoidCallback onSendOtp;
  final bool isSendingOtp;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verification',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Confirm your phone number and ID',
            style: TextStyle(color: AppColors.mutedText, fontSize: 14),
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: RegistrationTextField(
                  label: 'Phone number',
                  hintText: '98765 43210',
                  prefixText: '+91 ',
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 27),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSendingOtp ? null : onSendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.softBlue,
                      foregroundColor: AppColors.navy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isSendingOtp
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.navy,
                            ),
                          )
                        : const Text('Send OTP'),
                  ),
                ),
              ),
            ],
          ),

          RegistrationTextField(
            label: 'Enter OTP',
            hintText: '0  0  0  0  0  0',
            keyboardType: TextInputType.number,
            controller: otpController,
          ),
          RegistrationTextField(
            label: 'Aadhaar number',
            hintText: '0000 0000 0000',
            keyboardType: TextInputType.number,
            controller: aadhaarController,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}