import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../services/registration_service.dart';
import '../widgets/registration_text_field.dart';
import '../widgets/occupation_autocomplete_field.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({
    super.key,
    required this.nameController,
    required this.addressController,
    required this.cityController,
    required this.stateController,
    required this.occupationController,
    required this.experienceController,
    required this.descriptionController,
  });

  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController occupationController;
  final TextEditingController experienceController;
  final TextEditingController descriptionController;

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final RegistrationService registrationService = RegistrationService();

  List<String> _experienceRanges = [];
  bool _isLoadingExperience = true;

  @override
  void initState() {
    super.initState();
    _loadExperienceRanges();
  }

  Future<void> _loadExperienceRanges() async {
    final ranges = await registrationService.getExperienceRanges();

    if (!mounted) return;

    setState(() {
      _experienceRanges = ranges;
      _isLoadingExperience = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal information',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Tell us a bit about yourself',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 28),

          RegistrationTextField(
            label: 'Full name',
            controller: widget.nameController,
          ),

          RegistrationTextField(
            label: 'Address',
            controller: widget.addressController,
          ),

          Row(
            children: [
              Expanded(
                child: RegistrationTextField(
                  label: 'City',
                  hintText: 'Pune',
                  controller: widget.cityController,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: RegistrationTextField(
                  label: 'State',
                  hintText: 'Maharashtra',
                  controller: widget.stateController,
                ),
              ),
            ],
          ),

          OccupationAutocompleteField(
            controller: widget.occupationController,
          ),

          // Years of experience
          if (_isLoadingExperience)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_experienceRanges.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Unable to load experience options',
                style: TextStyle(
                  color: AppColors.mutedText,
                ),
              ),
            )
          else
            DropdownButtonFormField<String>(
              value: widget.experienceController.text.isEmpty
                  ? null
                  : widget.experienceController.text,
              decoration: InputDecoration(
                labelText: 'Years of experience',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: _experienceRanges.map((range) {
                return DropdownMenuItem<String>(
                  value: range,
                  child: Text(range),
                );
              }).toList(),
              onChanged: (value) {
                widget.experienceController.text = value ?? '';
              },
            ),

          RegistrationTextField(
            label: 'Description (optional)',
            hintText: 'Tools you own, shifts you prefer...',
            maxLines: 3,
            controller: widget.descriptionController,
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}