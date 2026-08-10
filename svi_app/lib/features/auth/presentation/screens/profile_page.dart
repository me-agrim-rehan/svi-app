import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/occupation_data.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../services/profile_service.dart';
import 'preferred_jobs_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.phone,
  });

  final String phone;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();

  UserProfile? _profile;
  bool _isLoading = true;

  Uint8List? _localPhotoBytes;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    final profile = await _profileService.fetchProfile(
      phone: widget.phone,
    );

    if (!mounted) return;

    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  Future<void> _pickProfilePhoto() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null || _profile == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      _localPhotoBytes = bytes;
      _isUploadingPhoto = true;
    });

    final newUrl = await _profileService.updateProfilePhoto(
      phone: widget.phone,
      photo: picked,
    );

    if (!mounted) return;

    setState(() {
      _isUploadingPhoto = false;

      if (newUrl != null) {
        _profile = _profile!.copyWith(
          profilePhotoUrl: newUrl,
        );
      }
    });

    if (newUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update photo. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> _editName() async {
    if (_profile == null) return;

    final controller = TextEditingController(
      text: _profile!.name,
    );

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Full name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              controller.text.trim(),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName == null ||
        newName.isEmpty ||
        newName == _profile!.name) {
      return;
    }

    final success = await _profileService.updateName(
      phone: widget.phone,
      name: newName,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _profile = _profile!.copyWith(
          name: newName,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update name. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> _editOccupation() async {
    if (_profile == null) return;

    final controller = TextEditingController(
      text: _profile!.occupation,
    );

    final newOccupation = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit occupation'),
        content: Autocomplete<String>(
          initialValue: TextEditingValue(
            text: _profile!.occupation,
          ),
          optionsBuilder: (TextEditingValue value) {
            if (value.text.trim().isEmpty) {
              return const Iterable<String>.empty();
            }

            return OccupationData.categoryTitles.where(
              (option) => option
                  .toLowerCase()
                  .contains(value.text.toLowerCase()),
            );
          },
          onSelected: (selection) {
            controller.text = selection;
          },
          fieldViewBuilder: (
            context,
            textController,
            focusNode,
            onSubmit,
          ) {
            return TextField(
              controller: textController,
              focusNode: focusNode,
              autofocus: true,
              onChanged: (val) {
                controller.text = val;
              },
              decoration: const InputDecoration(
                hintText:
                    'e.g. Mason, Electrician...',
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              controller.text.trim(),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newOccupation == null ||
        newOccupation.isEmpty ||
        newOccupation == _profile!.occupation) {
      return;
    }

    final success =
        await _profileService.updateOccupation(
      phone: widget.phone,
      occupation: newOccupation,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _profile = _profile!.copyWith(
          occupation: newOccupation,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update occupation. Please try again.',
          ),
        ),
      );
    }
  }

  // NEW
  Future<void> _editExperience() async {
    if (_profile == null) return;

    final controller = TextEditingController(
      text: _profile!.yearsOfExperience,
    );

    final newExperience = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit years of experience',
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'e.g. 5',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              controller.text.trim(),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newExperience == null ||
        newExperience.isEmpty ||
        newExperience == _profile!.yearsOfExperience) {
      return;
    }

    final success =
        await _profileService.updateYearsOfExperience(
      phone: widget.phone,
      yearsOfExperience: newExperience,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _profile = _profile!.copyWith(
          yearsOfExperience: newExperience,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> _openPreferredJobs() async {
    if (_profile == null) return;

    final updated = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => PreferredJobsPage(
          phone: widget.phone,
          selectedJobs: _profile!.preferredJobs,
          standalone: true,
          maxSelections: 10,
        ),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _profile = _profile!.copyWith(
          preferredJobs: updated,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_profile == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Couldn't load your profile.",
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadProfile,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          22,
          24,
          22,
          22,
        ),
        children: [
          Center(
            child: _buildAvatar(),
          ),

          const SizedBox(height: 16),

          Center(
            child: _EditableRow(
              text: _profile!.name.isNotEmpty
                  ? _profile!.name
                  : 'Add your name',
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              onEdit: _editName,
            ),
          ),

          const SizedBox(height: 4),

          Center(
            child: Text(
              _profile!.phone,
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Occupation
          _SectionCard(
            child: _EditableRow(
              label: 'Occupation',
              text: _profile!.occupation.isNotEmpty
                  ? _profile!.occupation
                  : 'Not set',
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              onEdit: _editOccupation,
            ),
          ),

          const SizedBox(height: 14),

          // NEW: Years of experience
          _SectionCard(
            child: _EditableRow(
              label: 'Years of experience',
              text: _profile!.yearsOfExperience.isNotEmpty
                  ? '${_profile!.yearsOfExperience} yrs'
                  : 'Not set',
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              onEdit: _editExperience,
            ),
          ),

          const SizedBox(height: 14),

          // Preferred jobs
          _SectionCard(
            child: InkWell(
              onTap: _openPreferredJobs,
              child: Row(
                children: [
                  const Icon(
                    Icons.work_outline,
                    color: AppColors.navy,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Preferred jobs',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _profile!.preferredJobs.isEmpty
                              ? 'None selected'
                              : '${_profile!.preferredJobs.length} selected',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.mutedText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    ImageProvider? imageProvider;

    if (_localPhotoBytes != null) {
      imageProvider = MemoryImage(
        _localPhotoBytes!,
      );
    } else if (_profile?.profilePhotoUrl != null &&
        _profile!.profilePhotoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(
        _profile!.profilePhotoUrl!,
      );
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: AppColors.softBlue,
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? Text(
                  _profile!.name.isNotEmpty
                      ? _profile!.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                )
              : null,
        ),

        if (_isUploadingPhoto)
          const Positioned.fill(
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Colors.black38,
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          ),

        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: _isUploadingPhoto
                ? null
                : _pickProfilePhoto,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.navy,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.edit,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.border,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _EditableRow extends StatelessWidget {
  const _EditableRow({
    this.label,
    required this.text,
    required this.textStyle,
    required this.onEdit,
  });

  final String? label;
  final String text;
  final TextStyle textStyle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize:
          label == null ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (label == null)
          Text(
            text,
            style: textStyle,
          )
        else
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: textStyle,
                ),
              ],
            ),
          ),

        const SizedBox(width: 8),

        InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.edit,
              size: 16,
              color: AppColors.mutedText,
            ),
          ),
        ),
      ],
    );
  }
}