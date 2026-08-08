import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/occupation_data.dart';

class OccupationAutocompleteField extends StatelessWidget {
  const OccupationAutocompleteField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Occupation',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue value) {
              if (value.text.trim().isEmpty) {
                return const Iterable<String>.empty();
              }
              // DB: once OccupationData.categoryTitles comes from the
              // backend, this filter logic stays the same.
              return OccupationData.categoryTitles.where(
                (option) =>
                    option.toLowerCase().contains(value.text.toLowerCase()),
              );
            },
            onSelected: (String selection) {
              controller.text = selection;
            },
            fieldViewBuilder: (context, textController, focusNode, onSubmit) {
              return TextFormField(
                controller: textController,
                focusNode: focusNode,
                onChanged: (val) => controller.text = val,
                decoration: InputDecoration(
                  hintText: 'Start typing e.g. Mason, Electrician, Welder...',
                  hintStyle: const TextStyle(color: AppColors.mutedText),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.navy,
                      width: 1.5,
                    ),
                  ),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Text(
                              option,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}