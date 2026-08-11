import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/applied_job.dart';
import '../../../../services/jobs_service.dart';
import '../widgets/applied_job_card.dart';

class AppliedJobsPage extends StatefulWidget {
  const AppliedJobsPage({super.key, required this.phone});

  final String phone;

  @override
  State<AppliedJobsPage> createState() => _AppliedJobsPageState();
}

class _AppliedJobsPageState extends State<AppliedJobsPage> {
  final JobsService _jobsService = JobsService();

  bool _isLoading = true;
  List<AppliedJob> _appliedJobs = [];

  @override
  void initState() {
    super.initState();
    _loadAppliedJobs();
  }

  Future<void> _loadAppliedJobs() async {
    setState(() => _isLoading = true);

    final jobs = await _jobsService.fetchAppliedJobs(phone: widget.phone);

    if (!mounted) return;

    setState(() {
      _appliedJobs = jobs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadAppliedJobs,
      child: CustomScrollView(
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(22, 18, 22, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Your applications',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_appliedJobs.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  "You haven't applied to any jobs yet.",
                  style: TextStyle(color: AppColors.mutedText),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => AppliedJobCard(job: _appliedJobs[index]),
                  childCount: _appliedJobs.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}