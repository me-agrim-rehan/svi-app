import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/registration_text_field.dart';
import '../widgets/occupation_autocomplete_field.dart';

class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({
    super.key,
    required this.nameController,
    required this.addressController,
    required this.cityController,
    required this.stateController,
    required this.occupationController,
    required this.descriptionController,
  });

  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController occupationController;
  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal information',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tell us a bit about yourself',
            style: TextStyle(color: AppColors.mutedText, fontSize: 14),
          ),
          const SizedBox(height: 28),

          RegistrationTextField(
            label: 'Full name',
            controller: nameController,
          ),
          RegistrationTextField(
            label: 'Address',
            controller: addressController,
          ),

          Row(
            children: [
              Expanded(
                child: RegistrationTextField(
                  label: 'City',
                  hintText: 'Pune',
                  controller: cityController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RegistrationTextField(
                  label: 'State',
                  hintText: 'Maharashtra',
                  controller: stateController,
                ),
              ),
            ],
          ),

          OccupationAutocompleteField(controller: occupationController),

          RegistrationTextField(
            label: 'Description (optional)',
            hintText: 'Years of experience, tools you own, shifts you prefer...',
            maxLines: 3,
            controller: descriptionController,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}