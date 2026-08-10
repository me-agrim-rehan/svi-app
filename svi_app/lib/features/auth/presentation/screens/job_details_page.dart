import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/job.dart';
import '../../../../services/jobs_service.dart';

class JobDetailsPage extends StatefulWidget {
  const JobDetailsPage({
    super.key,
    required this.jobId,
    this.initialJob,
  });

  /// The job's id — used to fetch full details from the backend.
  final String jobId;

  /// Optional: the Job object already shown on the home screen's card, if
  /// available. Shown immediately while the full fetch is in flight so the
  /// page isn't blank/loading for data we already have.
  final Job? initialJob;

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final JobsService _jobsService = JobsService();

  Job? _job;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _job = widget.initialJob;
    _isLoading = widget.initialJob == null;
    _loadJobDetail();
  }

  Future<void> _loadJobDetail() async {
    setState(() {
      _isLoading = _job == null;
      _hasError = false;
    });

    final fetched = await _jobsService.fetchJobDetail(jobId: widget.jobId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (fetched != null) {
        _job = fetched;
      } else if (_job == null) {
        _hasError = true;
      }
      // If fetch failed but we already had initialJob, just keep showing
      // that instead of erroring out.
    });
  }

  void _toggleBookmark() {
    if (_job == null) return;
    setState(() {
      _job!.isBookmarked = !_job!.isBookmarked;
      // TODO(DB): persist bookmark state to backend here.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _job == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Applying will be connected later.'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Apply now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 22, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          ),
          const Spacer(),
          if (_job != null)
            IconButton(
              onPressed: _toggleBookmark,
              icon: Icon(
                _job!.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: AppColors.navy,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError || _job == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Couldn't load this job.",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadJobDetail,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final job = _job!;

    return RefreshIndicator(
      onRefresh: _loadJobDetail,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              job.companyName.isNotEmpty ? job.companyName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColors.navy,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            job.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            job.companyName,
            style: const TextStyle(fontSize: 15, color: AppColors.mutedText),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (job.location.isNotEmpty)
                _DetailTag(icon: Icons.location_on_outlined, label: job.location),
              if (job.jobType.isNotEmpty)
                _DetailTag(icon: Icons.schedule_outlined, label: job.jobType),
              if (job.category.isNotEmpty)
                _DetailTag(
                  icon: Icons.category_outlined,
                  label: job.subCategory.isNotEmpty
                      ? '${job.category} · ${job.subCategory}'
                      : job.category,
                ),
            ],
          ),
          if (job.salaryRange.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined, color: AppColors.navy),
                  const SizedBox(width: 10),
                  Text(
                    job.salaryRange,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Job description',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            job.description.isNotEmpty
                ? job.description
                : 'No description provided for this job yet.',
            style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
          ),
          const SizedBox(height: 90), // keeps content clear of the Apply button
        ],
      ),
    );
  }
}

class _DetailTag extends StatelessWidget {
  const _DetailTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.mutedText),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}