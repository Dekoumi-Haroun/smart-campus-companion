import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../blocs/announcement/announcement_bloc.dart';
import '../../../blocs/announcement/announcement_state.dart';
import '../../../blocs/event/event_bloc.dart';
import '../../../blocs/event/event_state.dart';

class StatsSummaryRow extends StatelessWidget {
  const StatsSummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<AnnouncementBloc, AnnouncementState>(
            builder: (context, state) {
              final count =
                  state is AnnouncementLoaded ? state.announcements.length : 0;
              return _StatChip(
                icon: Icons.campaign_rounded,
                label: AppStrings.announcementsTitle,
                value: '$count',
                color: AppColors.secondary,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          // Events Today mirrors the Events calendar: both read EventBloc and
          // agree on which campus events fall on today's calendar date. The
          // previous implementation counted timetable classes by weekday,
          // which is why the home chip and the calendar could disagree.
          child: BlocBuilder<EventBloc, EventState>(
            builder: (context, state) {
              int count = 0;
              if (state is EventLoaded) {
                final today = DateTime.now();
                count = state.events.where((e) => e.occursOn(today)).length;
              }
              return _StatChip(
                icon: Icons.event_rounded,
                label: AppStrings.eventsToday,
                value: '$count',
                color: AppColors.warning,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: BlocBuilder<AnnouncementBloc, AnnouncementState>(
            builder: (context, state) {
              int count = 0;
              if (state is AnnouncementLoaded) {
                count = state.announcements.where((a) => a.isBookmarked).length;
              }
              return _StatChip(
                icon: Icons.notifications_active_rounded,
                label: AppStrings.alerts,
                value: '$count',
                color: AppColors.error,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
