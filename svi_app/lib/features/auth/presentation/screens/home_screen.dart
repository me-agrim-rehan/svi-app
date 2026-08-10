import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/job.dart';
import '../../../../services/jobs_service.dart';
import '../widgets/job_card.dart';
import '../widgets/app_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.phone});

  final String phone;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JobsService _jobsService = JobsService();
  final TextEditingController _searchController = TextEditingController();

  int _bottomNavIndex = 0;
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

    final results = await Future.wait([
      _jobsService.fetchAllJobs(),
      _jobsService.fetchUserProfile(phone: widget.phone),
    ]);

    if (!mounted) return;

    final allJobs = results[0] as List<Job>;
    final profile = results[1] as UserJobProfile;

    setState(() {
      _sortedJobs = _sortJobsByPriority(allJobs, profile);
      _isLoading = false;
    });
  }

  List<Job> _sortJobsByPriority(List<Job> allJobs, UserJobProfile profile) {
    final seenIds = <String>{};
    final result = <Job>[];

    for (final job in allJobs) {
      final jobKey = '${job.category}|${job.subCategory}';
      if (profile.preferredJobs.contains(jobKey) && seenIds.add(job.id)) {
        result.add(job);
      }
    }

    if (profile.occupationCategory.isNotEmpty) {
      for (final job in allJobs) {
        if (job.category == profile.occupationCategory &&
            seenIds.add(job.id)) {
          result.add(job);
        }
      }
    }

    for (final job in allJobs) {
      if (job.skillLevel == JobSkillLevel.unskilled && seenIds.add(job.id)) {
        result.add(job);
      }
    }

    return result;
  }

  void _toggleBookmark(Job job) {
    setState(() {
      job.isBookmarked = !job.isBookmarked;
      // TODO(DB): persist bookmark state to backend here.
    });
  }

  void _handleMenuSelection(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$value will be connected later.')),
    );
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
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadJobs,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.construction_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Notifications will be connected later.'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.notifications_none_rounded),
                            color: AppColors.navy,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: AppColors.navy),
                        onSelected: _handleMenuSelection,
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'Settings', child: Text('Settings')),
                          PopupMenuItem(value: 'Help & support', child: Text('Help & support')),
                          PopupMenuItem(value: 'Log out', child: Text('Log out')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                sliver: SliverToBoxAdapter(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search for roles, skills, or locations...',
                      hintStyle: const TextStyle(color: AppColors.mutedText, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: AppColors.mutedText),
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
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final job = _filteredJobs[index];
                        return JobCard(
                          job: job,
                          onBookmarkToggle: () => _toggleBookmark(job),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${job.title} details coming soon.')),
                            );
                          },
                        );
                      },
                      childCount: _filteredJobs.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          if (index != 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This section is coming soon.')),
            );
          }
        },
      ),
    );
  }
}