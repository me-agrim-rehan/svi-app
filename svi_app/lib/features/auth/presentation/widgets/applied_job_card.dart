import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/applied_job.dart';

class AppliedJobCard extends StatelessWidget {
  const AppliedJobCard({super.key, required this.job, this.onTap});

  final AppliedJob job;
  final VoidCallback? onTap;

  _StatusStyle get _style {
    switch (job.status.toLowerCase()) {
      case 'accepted':
        return const _StatusStyle(
          label: 'Accepted',
          background: Color(0xFFEAF7EE),
          border: Color(0xFF34A853),
          text: Color(0xFF1E7A34),
        );

      case 'rejected':
        return const _StatusStyle(
          label: 'Rejected',
          background: Color(0xFFFDECEC),
          border: Color(0xFFE53935),
          text: Color(0xFFC62828),
        );

      case 'processing':
        return const _StatusStyle(
          label: 'In progress',
          background: Color(0xFFFFF8E1),
          border: Color(0xFFF9A825),
          text: Color(0xFF8D6E00),
        );

      default:
        return const _StatusStyle(
          label: 'Unknown',
          background: Color(0xFFF5F5F5),
          border: Color(0xFFBDBDBD),
          text: Color(0xFF616161),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: style.border, width: 1.2),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: style.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: style.border),
                  ),
                  child: Text(
                    style.label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: style.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (job.location.isNotEmpty) ...[
                  _Tag(label: job.location),
                  const SizedBox(width: 8),
                ],
                if (job.jobType.isNotEmpty) _Tag(label: job.jobType),
              ],
            ),
            if (job.salaryRange.isNotEmpty) ...[
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
          ],
        ),
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.background,
    required this.border,
    required this.text,
  });

  final String label;
  final Color background;
  final Color border;
  final Color text;
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
