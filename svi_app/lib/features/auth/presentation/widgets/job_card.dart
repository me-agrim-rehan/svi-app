import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/job.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    required this.onBookmarkToggle,
    this.onTap,
  });

  final Job job;
  final VoidCallback onBookmarkToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    job.companyName.isNotEmpty
                        ? job.companyName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.companyName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onBookmarkToggle,
                  icon: Icon(
                    job.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: AppColors.navy,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              job.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.mutedText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Tag(label: job.location),
                const SizedBox(width: 8),
                _Tag(label: job.workMode),
                const SizedBox(width: 8),
                _Tag(label: job.jobType),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              job.salaryRange,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.mutedText,
        ),
      ),
    );
  }
}