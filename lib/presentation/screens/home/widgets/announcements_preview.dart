import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/announcement.dart';
import '../../../blocs/announcement/announcement_bloc.dart';
import '../../../blocs/announcement/announcement_state.dart';
import '../../../widgets/main_shell.dart';
import 'announcement_detail_sheet.dart';
import 'home_section_header.dart';

class AnnouncementsPreview extends StatelessWidget {
  const AnnouncementsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: AppStrings.announcements,
          onSeeAll: () {
            final shell = context.findAncestorStateOfType<MainShellState>();
            shell?.switchTab(1);
          },
        ),
        const SizedBox(height: 10),
        BlocBuilder<AnnouncementBloc, AnnouncementState>(
          builder: (context, state) {
            if (state is AnnouncementLoading) {
              return const SizedBox(
                height: 130,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is AnnouncementError) {
              return SizedBox(
                height: 130,
                child: Center(
                  child: Text(
                    state.message,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              );
            }
            if (state is AnnouncementLoaded) {
              if (state.announcements.isEmpty) {
                return const SizedBox(
                  height: 130,
                  child: Center(child: Text(AppStrings.noAnnouncements)),
                );
              }
              return SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.announcements.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final a = state.announcements[index];
                    return _AnnouncementMiniCard(
                      announcement: a,
                      onTap: () => showAnnouncementDetailSheet(context, a),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _AnnouncementMiniCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;

  const _AnnouncementMiniCard({
    required this.announcement,
    required this.onTap,
  });

  Color _tagColor(String category) {
    return switch (category.toLowerCase()) {
      'academic' => AppColors.tagAcademic,
      'sports' => AppColors.tagSports,
      'urgent' => AppColors.tagUrgent,
      'administration' => AppColors.tagAdministration,
      'it' => AppColors.tagIt,
      'wellness' => AppColors.tagWellness,
      _ => AppColors.tagGeneral,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _tagColor(announcement.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                announcement.category,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              announcement.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              DateFormat('MMM d, yyyy').format(announcement.date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
