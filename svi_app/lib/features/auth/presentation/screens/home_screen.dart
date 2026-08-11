import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/job.dart';
import '../../../../services/jobs_service.dart';
import '../widgets/job_card.dart';
import 'job_details_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.phone});

  final String phone;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JobsService _jobsService = JobsService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<Job> _sortedJobs = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);

    try {
      final profile = await _jobsService.fetchUserProfile(phone: widget.phone);

      if (profile.userId.isEmpty) {
        throw Exception("User ID not found");
      }

      final recommendedJobs = await _jobsService.fetchRecommendedJobs(
        userId: profile.userId,
      );

      if (!mounted) return;

      setState(() {
        _sortedJobs = recommendedJobs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _sortedJobs = [];
        _isLoading = false;
      });

      debugPrint("Error loading recommended jobs: $e");
    }
  }

  void _toggleBookmark(Job job) {
    setState(() {
      job.isBookmarked = !job.isBookmarked;
      // TODO(DB): persist bookmark state to backend here.
    });
  }

  List<Job> get _filteredJobs {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _sortedJobs;
    return _sortedJobs.where((job) {
      return job.title.toLowerCase().contains(query) ||
          job.companyName.toLowerCase().contains(query) ||
          job.category.toLowerCase().contains(query) ||
          job.subCategory.toLowerCase().contains(query) ||
          job.location.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search for roles, skills, or locations...',
                  hintStyle: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.mutedText,
                  ),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Recommended for you',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredJobs.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No matching jobs found yet.',
                  style: TextStyle(color: AppColors.mutedText),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final job = _filteredJobs[index];
                  return JobCard(
                    job: job,
                    onBookmarkToggle: () => _toggleBookmark(job),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailsPage(
                            jobId: job.id,
                            phone: widget.phone,
                            initialJob: job,
                          ),
                        ),
                      );
                    },
                  );
                }, childCount: _filteredJobs.length),
              ),
            ),
        ],
      ),
    );
  }
}
