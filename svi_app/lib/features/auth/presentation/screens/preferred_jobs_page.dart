// preferred_jobs_page.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/occupation_data.dart';

class PreferredJobsPage extends StatefulWidget {
  const PreferredJobsPage({
    super.key,
    required this.selectedJobs,
    this.onToggle,
    this.maxSelections = 10,
    this.showSaveButton = false,
  });

  // Stores job_subcategory IDs as strings.
  // Example: ["7", "12", "15"]
  final List<String> selectedJobs;

  // Used by registration.
  // Profile editing can leave this null because this page
  // manages its own temporary selection.
  final void Function(String jobId)? onToggle;

  final int maxSelections;

  // True when this page is opened from ProfilePage.
  final bool showSaveButton;

  @override
  State<PreferredJobsPage> createState() =>
      _PreferredJobsPageState();
}

class _PreferredJobsPageState
    extends State<PreferredJobsPage> {
  late List<String> _selectedJobs;
  bool _isLoadingOccupations = true;

  @override
  void initState() {
    super.initState();

    // Make a copy so we don't directly modify the parent's list.
    _selectedJobs = List<String>.from(widget.selectedJobs);

    _loadOccupations();
  }

  Future<void> _loadOccupations() async {
    // Loads job categories from the backend if they haven't been fetched
    // yet in this app session. Without this, opening Preferred Jobs before
    // ever visiting the Occupation editor shows a blank list — the data
    // was never fetched.
    await OccupationData.load();

    if (!mounted) return;

    setState(() => _isLoadingOccupations = false);
  }

  void _toggleJob(String jobId) {
    setState(() {
      if (_selectedJobs.contains(jobId)) {
        _selectedJobs.remove(jobId);
      } else {
        if (_selectedJobs.length >= widget.maxSelections) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You can only select up to '
                '${widget.maxSelections} jobs',
              ),
            ),
          );
          return;
        }

        _selectedJobs.add(jobId);
      }
    });

    // Notify parent when used from registration.
    widget.onToggle?.call(jobId);
  }

  void _save() {
    Navigator.pop(
      context,
      List<String>.from(_selectedJobs),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingOccupations) {
      final loadingContent = const Center(child: CircularProgressIndicator());

      if (!widget.showSaveButton) {
        return loadingContent;
      }

      return Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          backgroundColor: AppColors.pageBackground,
          elevation: 0,
          foregroundColor: Colors.black,
          title: const Text('Preferred jobs'),
        ),
        body: loadingContent,
      );
    }

    final bool limitReached =
        _selectedJobs.length >= widget.maxSelections;

    final content = Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                  'Pick up to ${widget.maxSelections} '
                  '(${_selectedJobs.length}/'
                  '${widget.maxSelections} selected)',
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 24),

                for (final entry
                    in OccupationData.categories.entries)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 22,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
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
                          children:
                              entry.value.map((subrole) {
                            final String jobId =
                                subrole.id.toString();

                            final bool isSelected =
                                _selectedJobs
                                    .contains(jobId);

                            final bool isDisabled =
                                !isSelected &&
                                limitReached;

                            return ChoiceChip(
                              label: Text(
                                subrole.name,
                              ),
                              selected: isSelected,
                              onSelected: isDisabled
                                  ? null
                                  : (_) =>
                                      _toggleJob(jobId),
                              selectedColor:
                                  AppColors.navy,
                              backgroundColor:
                                  AppColors
                                      .inputBackground,
                              labelStyle:
                                  TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDisabled
                                        ? AppColors
                                            .mutedText
                                            .withOpacity(
                                              0.5,
                                            )
                                        : Colors.black),
                                fontWeight:
                                    FontWeight.w500,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.navy
                                    : AppColors.border,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),
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
          ),
        ),

        if (widget.showSaveButton)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                22,
                10,
                22,
                16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save preferred jobs',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    // Standalone (opened from Profile) needs its own Scaffold + back
    // button. Embedded in registration's PageView, the parent already
    // provides a Scaffold, so just return the bare content.
    if (!widget.showSaveButton) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('Preferred jobs'),
      ),
      body: content,
    );
  }
}