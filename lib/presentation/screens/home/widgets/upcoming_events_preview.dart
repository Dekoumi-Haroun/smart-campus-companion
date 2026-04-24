import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/event.dart';
import '../../../blocs/event/event_bloc.dart';
import '../../../blocs/event/event_state.dart';
import '../../../widgets/main_shell.dart';
import 'event_detail_sheet.dart';
import 'home_section_header.dart';

class UpcomingEventsPreview extends StatelessWidget {
  const UpcomingEventsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: AppStrings.upcomingEvents.toUpperCase(),
          onSeeAll: () {
            final shell = context.findAncestorStateOfType<MainShellState>();
            shell?.switchTab(2);
          },
        ),
        const SizedBox(height: 10),
        BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            if (state is EventLoading) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is EventError) {
              return SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    state.message,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              );
            }
            if (state is EventLoaded) {
              // Upcoming = not yet completed. Sort nearest-first so the top
              // card always represents what the user should care about next.
              final now = DateTime.now();
              final upcoming = state.events
                  .where((e) => e.statusAt(now) != EventStatus.completed)
                  .toList()
                ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

              if (upcoming.isEmpty) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: Text(AppStrings.noEvents)),
                );
              }
              return SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: upcoming.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final e = upcoming[index];
                    return _EventMiniCard(
                      event: e,
                      onTap: () => showEventDetailSheet(context, e),
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

class _EventMiniCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventMiniCard({required this.event, required this.onTap});

  IconData _categoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'workshop' => Icons.build_rounded,
      'sports' => Icons.sports_basketball_rounded,
      'career' => Icons.work_rounded,
      'social' => Icons.music_note_rounded,
      'academic' => Icons.school_rounded,
      _ => Icons.event_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _categoryIcon(event.category),
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, h:mm a').format(event.dateTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
