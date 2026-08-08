import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/occupation_data.dart';

class PreferredJobsPage extends StatelessWidget {
  const PreferredJobsPage({
    super.key,
    required this.selectedJobs,
    required this.onToggle,
    this.maxSelections = 10,
  });

  final List<String> selectedJobs; // stores "Category|Subrole" strings
  final void Function(String jobKey) onToggle;
  final int maxSelections;

  @override
  Widget build(BuildContext context) {
    final bool limitReached = selectedJobs.length >= maxSelections;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferred jobs',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick up to $maxSelections (${selectedJobs.length}/$maxSelections selected)',
            style: const TextStyle(color: AppColors.mutedText, fontSize: 14),
          ),
          const SizedBox(height: 24),

          for (final entry in OccupationData.categories.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.value.map((subrole) {
                      final jobKey = '${entry.key}|$subrole';
                      final isSelected = selectedJobs.contains(jobKey);
                      final isDisabled = !isSelected && limitReached;

                      return ChoiceChip(
                        label: Text(subrole),
                        selected: isSelected,
                        onSelected: isDisabled
                            ? null
                            : (_) => onToggle(jobKey),
                        selectedColor: AppColors.navy,
                        backgroundColor: AppColors.inputBackground,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDisabled
                                  ? AppColors.mutedText.withOpacity(0.5)
                                  : Colors.black),
                          fontWeight: FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.navy : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}