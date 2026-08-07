import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/registration_service.dart';
import 'personal_info_page.dart';
import 'verification_page.dart';
import 'documents_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0; // 0 = Verification, 1 = Personal Info, 2 = Documents

  final AuthService authService = AuthService();
  final RegistrationService registrationService = RegistrationService();

  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _otpVerified = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _occupationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _otpController = TextEditingController();
  final _aadhaarController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _occupationController.dispose();
    _descriptionController.dispose();
    _otpController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature will be connected later.')),
    );
  }

  Future<void> _handleSendOtp() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() => _isSendingOtp = true);
    final success = await authService.sendOtp(_phoneController.text.trim());
    setState(() => _isSendingOtp = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'OTP sent successfully' : 'Failed to send OTP')),
    );
  }

  Future<bool> _handleVerifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP')),
      );
      return false;
    }

    setState(() => _isVerifyingOtp = true);
    final success = await authService.verifyOtp(
      _phoneController.text.trim(),
      _otpController.text.trim(),
    );
    setState(() {
      _isVerifyingOtp = false;
      _otpVerified = success;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'OTP verified' : 'Invalid OTP, try again')),
    );

    return success;
  }

  // --------------------------------------------------------------------
  // 🔌 BACKEND HOOKS — fire-and-forget for now (not awaited, don't block
  // navigation). See registration_service.dart for endpoint placeholders.
  // Once real endpoints exist: await these and gate _goNext on success,
  // same pattern as _handleVerifyOtp above.
  // --------------------------------------------------------------------
  void _submitAadhaarNumber() {
    registrationService.submitAadhaarNumber(
      phone: _phoneController.text.trim(),
      aadhaarNumber: _aadhaarController.text.trim(),
    );
  }

  void _submitPersonalInfo() {
    registrationService.submitPersonalInfo(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      occupation: _occupationController.text.trim(),
      description: _descriptionController.text.trim(),
    );
  }

  void _submitDocuments() {
    registrationService.submitDocuments(
      phone: _phoneController.text.trim(),
    );
  }
  // --------------------------------------------------------------------

  Future<void> _goNext() async {
    if (_currentPage == 0) {
      if (!_otpVerified) {
        final verified = await _handleVerifyOtp();
        if (!verified) return;
      }
      _submitAadhaarNumber();
    }

    if (_currentPage == 1) {
      _submitPersonalInfo();
    }

    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitDocuments();
      _showComingSoon('Account creation');
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i != 2 ? 8 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _currentPage ? AppColors.navy : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  VerificationPage(
                    phoneController: _phoneController,
                    otpController: _otpController,
                    aadhaarController: _aadhaarController,
                    onSendOtp: _handleSendOtp,
                    isSendingOtp: _isSendingOtp,
                  ),
                  PersonalInfoPage(
                    nameController: _nameController,
                    addressController: _addressController,
                    cityController: _cityController,
                    stateController: _stateController,
                    occupationController: _occupationController,
                    descriptionController: _descriptionController,
                  ),
                  DocumentsPage(
                    onUpload: () => _showComingSoon('Photo upload'),
                    onOpenCamera: () => _showComingSoon('Camera verification'),
                    onCreateAccount: _goNext,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _goBack,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          foregroundColor: AppColors.navy,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isVerifyingOtp ? null : _goNext,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isVerifyingOtp
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _currentPage < 2 ? 'Next' : 'Create account',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}