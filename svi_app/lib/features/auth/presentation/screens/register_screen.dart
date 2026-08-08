import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/registration_service.dart';
import 'verification_page.dart';
import 'personal_info_page.dart';
import 'documents_page.dart';
import 'preferred_jobs_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const int _totalPages = 4;
  static const int _maxPreferredJobs = 3;

  final PageController _pageController = PageController();

  int _currentPage = 0;

  final AuthService authService = AuthService();
  final RegistrationService registrationService = RegistrationService();

  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _isCreatingAccount = false;
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

  final List<String> _selectedPreferredJobs = [];

  XFile? _aadhaarImage;
  XFile? _selfieImage;

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

  Future<void> _handleSendOtp() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number'),
        ),
      );
      return;
    }

    setState(() {
      _isSendingOtp = true;
    });

    final success = await authService.sendOtp(
      _phoneController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSendingOtp = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'OTP sent successfully'
              : 'Failed to send OTP',
        ),
      ),
    );
  }

  Future<bool> _handleVerifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the OTP'),
        ),
      );

      return false;
    }

    setState(() {
      _isVerifyingOtp = true;
    });

    final success = await authService.verifyOtp(
      _phoneController.text.trim(),
      _otpController.text.trim(),
    );

    if (!mounted) return false;

    setState(() {
      _isVerifyingOtp = false;
      _otpVerified = success;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'OTP verified'
              : 'Invalid OTP, try again',
        ),
      ),
    );

    return success;
  }

  void _togglePreferredJob(String jobKey) {
    setState(() {
      if (_selectedPreferredJobs.contains(jobKey)) {
        _selectedPreferredJobs.remove(jobKey);
      } else if (_selectedPreferredJobs.length < _maxPreferredJobs) {
        _selectedPreferredJobs.add(jobKey);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can only select up to $_maxPreferredJobs jobs',
            ),
          ),
        );
      }
    });
  }

  Future<void> _createAccount() async {
    if (_aadhaarImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your Aadhaar photo'),
        ),
      );

      await _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      return;
    }

    if (_selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take your selfie'),
        ),
      );

      await _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
        ),
      );

      await _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      return;
    }

    if (_addressController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your address details'),
        ),
      );

      await _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      return;
    }

    if (_occupationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your occupation'),
        ),
      );

      await _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      return;
    }

    if (_aadhaarController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Aadhaar number'),
        ),
      );

      await _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      return;
    }

    setState(() {
      _isCreatingAccount = true;
    });

    final success = await registrationService.createAccount(
      phone: _phoneController.text.trim(),
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      occupation: _occupationController.text.trim(),
      description: _descriptionController.text.trim(),
      aadhaarNumber: _aadhaarController.text.trim(),
      aadhaarPhoto: _aadhaarImage!,
      livePhoto: _selfieImage!,
    );

    if (!mounted) return;

    setState(() {
      _isCreatingAccount = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully'),
        ),
      );

      // TODO:
      // Navigate to your dashboard/home page here.
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account creation failed. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> _goNext() async {
    // ---------------------------------------------------------------
    // PAGE 0: OTP verification
    // ---------------------------------------------------------------
    if (_currentPage == 0) {
      if (!_otpVerified) {
        final verified = await _handleVerifyOtp();

        if (!verified) {
          return;
        }
      }

      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      return;
    }

    // ---------------------------------------------------------------
    // PAGE 1: Personal information
    // ---------------------------------------------------------------
    if (_currentPage == 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      return;
    }

    // ---------------------------------------------------------------
    // PAGE 2: Documents
    // ---------------------------------------------------------------
    if (_currentPage == 2) {
      if (_aadhaarImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload your Aadhaar photo'),
          ),
        );
        return;
      }

      if (_selfieImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please take your selfie'),
          ),
        );
        return;
      }

      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      return;
    }

    // ---------------------------------------------------------------
    // PAGE 3: Preferred jobs → Create account
    // ---------------------------------------------------------------
    if (_currentPage == 3) {
      await _createAccount();
    }
  }

  void _goBack() {
    if (_currentPage > 0 && !_isCreatingAccount) {
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
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 12,
              ),
              child: Row(
                children: List.generate(
                  _totalPages,
                  (i) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: i != _totalPages - 1 ? 8 : 0,
                        ),
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= _currentPage
                              ? AppColors.navy
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) {
                  setState(() {
                    _currentPage = i;
                  });
                },
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
                    onAadhaarImagePicked: (file) {
                      setState(() {
                        _aadhaarImage = file;
                      });
                    },
                    onSelfieImagePicked: (file) {
                      setState(() {
                        _selfieImage = file;
                      });
                    },
                    onCreateAccount: _goNext,
                  ),

                  PreferredJobsPage(
                    selectedJobs: _selectedPreferredJobs,
                    onToggle: _togglePreferredJob,
                    maxSelections: _maxPreferredJobs,
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
                        onPressed: _isCreatingAccount
                            ? null
                            : _goBack,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          foregroundColor: AppColors.navy,
                          side: const BorderSide(
                            color: AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),

                  if (_currentPage > 0)
                    const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          (_isVerifyingOtp || _isCreatingAccount)
                              ? null
                              : _goNext,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isVerifyingOtp || _isCreatingAccount
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _currentPage == _totalPages - 1
                                  ? 'Create account'
                                  : 'Next',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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