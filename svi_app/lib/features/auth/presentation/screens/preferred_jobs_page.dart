// preferred_jobs_page.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/occupation_data.dart';
import '../../../../services/profile_service.dart';

class PreferredJobsPage extends StatefulWidget {
  const PreferredJobsPage({
    super.key,
    this.selectedJobs,
    this.onToggle,
    this.phone,
    this.standalone = false,
    this.maxSelections = 10,
  });

  final List<String> selectedJobs; // stores "Category|Subrole" strings
  final void Function(String jobKey) onToggle;
  final int maxSelections;

  @override
  State<PreferredJobsPage> createState() => _PreferredJobsPageState();
}

class _PreferredJobsPageState extends State<PreferredJobsPage> {
  final ProfileService _profileService = ProfileService();

  late List<String> _localSelection;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Only used in standalone mode — controlled mode always reads
    // widget.selectedJobs directly, never this local copy.
    _localSelection = List.from(widget.selectedJobs ?? []);
  }

  List<String> get _currentSelection =>
      widget.standalone ? _localSelection : (widget.selectedJobs ?? []);

  bool get _limitReached => _currentSelection.length >= widget.maxSelections;

  void _handleToggle(String jobKey) {
    if (widget.standalone) {
      setState(() {
        if (_localSelection.contains(jobKey)) {
          _localSelection.remove(jobKey);
        } else if (_localSelection.length < widget.maxSelections) {
          _localSelection.add(jobKey);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You can only select up to ${widget.maxSelections} jobs'),
            ),
          );
        }
      });
    } else {
      widget.onToggle?.call(jobKey);
    }
  }

  Future<void> _save() async {
    if (widget.phone == null) return;

    setState(() => _isSaving = true);

    final success = await _profileService.updatePreferredJobs(
      phone: widget.phone!,
      preferredJobs: _localSelection,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context, _localSelection);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildChipList();

    if (!widget.standalone) {
      // Controlled mode: just the picker, no Scaffold — the parent
      // (register_screen.dart's PageView) provides the surrounding chrome.
      return content;
    }

    // Standalone mode: full page with back button + Save button.
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 22, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.navy),
                  ),
                  const Text(
                    'Edit preferred jobs',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Expanded(child: content),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChipList() {
    final selected = _currentSelection;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferred jobs',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
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
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
                        // Display the name to the user
                        label: Text(subrole.name),

                        selected: isSelected,
                        onSelected: isDisabled
                            ? null
                            : (_) => onToggle(jobKey),
                        selectedColor: AppColors.navy,

                        backgroundColor:
                            AppColors.inputBackground,

                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDisabled
                                  ? AppColors.mutedText
                                      .withOpacity(0.5)
                                  : Colors.black),
                          fontWeight: FontWeight.w500,
                        ),

                        side: BorderSide(
                          color: isSelected
                              ? AppColors.navy
                              : AppColors.border,
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