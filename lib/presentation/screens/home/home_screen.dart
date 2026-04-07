import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/announcement.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/timetable_item.dart';
import '../../blocs/announcement/announcement_bloc.dart';
import '../../blocs/announcement/announcement_state.dart';
import '../../blocs/connectivity/connectivity_cubit.dart';
import '../../blocs/connectivity/connectivity_state.dart';
import '../../blocs/event/event_bloc.dart';
import '../../blocs/event/event_event.dart';
import '../../blocs/event/event_state.dart';
import '../../blocs/timetable/timetable_bloc.dart';
import '../../blocs/timetable/timetable_event.dart';
import '../../blocs/timetable/timetable_state.dart';
import '../../widgets/main_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(theme: theme),
              const SizedBox(height: 20),
              const _CurrentClassCard(),
              const SizedBox(height: 20),
              const _StatsSummaryRow(),
              const SizedBox(height: 24),
              const _AnnouncementsPreview(),
              const SizedBox(height: 24),
              const _UpcomingEventsPreview(),
              const SizedBox(height: 24),
              const _BottomActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final ThemeData theme;

  const _Header({required this.theme});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${_greeting()}, ${AppStrings.userName}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<ConnectivityCubit, ConnectivityState>(
                    builder: (context, connState) {
                      final isOffline = connState is ConnectivityOffline;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isOffline
                              ? AppColors.warning
                              : AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOffline ? AppStrings.offline : AppStrings.live,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        _ProfileAvatar(theme: theme),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final ThemeData theme;

  const _ProfileAvatar({required this.theme});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'sign_out') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign out — Coming in Sprint 6')),
          );
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.userName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                AppStrings.userEmail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Divider(),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.person_outline_rounded),
            title: Text(AppStrings.viewProfile),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'sign_out',
          child: ListTile(
            leading: Icon(Icons.logout_rounded, color: AppColors.error),
            title: Text(AppStrings.signOut),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      child: CircleAvatar(
        radius: 22,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
        child: Text(
          AppStrings.userName[0].toUpperCase(),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CURRENT CLASS CARD
// ═══════════════════════════════════════════════════════════════════

class _CurrentClassCard extends StatelessWidget {
  const _CurrentClassCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, connState) {
        final isOffline = connState is ConnectivityOffline;

        return BlocBuilder<TimetableBloc, TimetableState>(
          builder: (context, state) {
            if (state is TimetableLoading) {
              return _buildCardShell(
                context,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              );
            }
            if (state is TimetableError) {
              return _buildCardShell(
                context,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }
            if (state is TimetableLoaded) {
              final today = DateTime.now().weekday;
              final todayClasses =
                  state.items.where((i) => i.dayOfWeek == today).toList()
                    ..sort((a, b) => a.startTime.compareTo(b.startTime));

              final currentOrNext = _findCurrentOrNext(todayClasses);
              final completed = todayClasses
                  .where((c) => c.status == 'Completed')
                  .length;

              return GestureDetector(
                onTap: () => _showTodayScheduleSheet(context, todayClasses),
                child: _buildCardShell(
                  context,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: currentOrNext != null
                        ? _buildClassInfo(
                            context,
                            currentOrNext,
                            completed,
                            todayClasses.length,
                            isOffline: isOffline,
                          )
                        : _buildNoClass(context),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildCardShell(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  TimetableItem? _findCurrentOrNext(List<TimetableItem> todayClasses) {
    for (final c in todayClasses) {
      if (c.status == 'In Progress') return c;
    }
    for (final c in todayClasses) {
      if (c.status == 'Upcoming') return c;
    }
    return todayClasses.isNotEmpty ? todayClasses.last : null;
  }

  Widget _buildClassInfo(
    BuildContext context,
    TimetableItem item,
    int completed,
    int total, {
    bool isOffline = false,
  }) {
    final isNow = item.status == 'In Progress';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (isNow)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  AppStrings.now,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            const Spacer(),
            Text(
              isOffline ? '--' : '${item.startTime} - ${item.endTime}',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          item.courseName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.person_outline, color: Colors.white54, size: 16),
            const SizedBox(width: 4),
            Text(
              item.instructor,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.room_outlined, color: Colors.white54, size: 16),
            const SizedBox(width: 4),
            Text(
              item.room,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? completed / total : 0,
            minHeight: 6,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isOffline
              ? 'Last synced: 5 min ago'
              : '$completed of $total ${AppStrings.classesCompleted}',
          style: TextStyle(
            color: isOffline ? AppColors.warning : Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildNoClass(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.free_breakfast_rounded, color: Colors.white38, size: 40),
        SizedBox(height: 8),
        Text(
          AppStrings.noClassNow,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// STATS SUMMARY ROW
// ═══════════════════════════════════════════════════════════════════

class _StatsSummaryRow extends StatelessWidget {
  const _StatsSummaryRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<AnnouncementBloc, AnnouncementState>(
            builder: (context, state) {
              final count = state is AnnouncementLoaded
                  ? state.announcements.length
                  : 0;
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
          child: BlocBuilder<TimetableBloc, TimetableState>(
            builder: (context, state) {
              // "Events Today" shows how many timetable items today
              int count = 0;
              if (state is TimetableLoaded) {
                final today = DateTime.now().weekday;
                count = state.items.where((i) => i.dayOfWeek == today).length;
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
              // Alerts = bookmarked announcements count
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
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

// ═══════════════════════════════════════════════════════════════════
// ANNOUNCEMENTS PREVIEW
// ═══════════════════════════════════════════════════════════════════

class _AnnouncementsPreview extends StatelessWidget {
  const _AnnouncementsPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
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
                      onTap: () => _showAnnouncementDetailSheet(context, a),
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

// ═══════════════════════════════════════════════════════════════════
// UPCOMING EVENTS PREVIEW
// ═══════════════════════════════════════════════════════════════════

class _UpcomingEventsPreview extends StatelessWidget {
  const _UpcomingEventsPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
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
              if (state.events.isEmpty) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: Text(AppStrings.noEvents)),
                );
              }
              return SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.events.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final e = state.events[index];
                    return _EventMiniCard(
                      event: e,
                      onTap: () => _showEventDetailSheet(context, e),
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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

// ═══════════════════════════════════════════════════════════════════
// BOTTOM ACTION BUTTONS
// ═══════════════════════════════════════════════════════════════════

class _BottomActionButtons extends StatelessWidget {
  const _BottomActionButtons();

  @override
  Widget build(BuildContext context) {
    return BlocListener<TimetableBloc, TimetableState>(
      listener: (context, state) {
        if (state is TimetableExported) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Schedule exported to:\n${state.filePath}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<TimetableBloc>().add(const ExportTimetable());
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text(AppStrings.exportSchedule),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.campusSafetyComingSoon),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.shield_rounded),
              label: const Text(AppStrings.campusSafety),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SHARED SECTION HEADER
// ═══════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        TextButton(onPressed: onSeeAll, child: const Text(AppStrings.seeAll)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// BOTTOM SHEETS
// ═══════════════════════════════════════════════════════════════════

void _showTodayScheduleSheet(
  BuildContext context,
  List<TimetableItem> classes,
) {
  final theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.todaysSchedule,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: classes.isEmpty
                      ? const Center(child: Text('No classes today'))
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: classes.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final c = classes[index];
                            return _ScheduleTile(item: c);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _ScheduleTile extends StatelessWidget {
  final TimetableItem item;

  const _ScheduleTile({required this.item});

  Color _statusColor() {
    return switch (item.status) {
      'Completed' => AppColors.success,
      'In Progress' => AppColors.warning,
      _ => AppColors.info,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: _statusColor(), width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.courseName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.startTime} - ${item.endTime}  •  ${item.room}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor().withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.status,
              style: TextStyle(
                color: _statusColor(),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showAnnouncementDetailSheet(
  BuildContext context,
  Announcement announcement,
) {
  final theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  announcement.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, yyyy').format(announcement.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (announcement.source.isNotEmpty) ...[
                      Icon(
                        Icons.source_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        announcement.source,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  announcement.body,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SheetAction(
                      icon: Icons.share_rounded,
                      label: AppStrings.share,
                      onTap: () => Navigator.pop(context),
                    ),
                    _SheetAction(
                      icon: Icons.bookmark_border_rounded,
                      label: AppStrings.save,
                      onTap: () => Navigator.pop(context),
                    ),
                    _SheetAction(
                      icon: Icons.notifications_none_rounded,
                      label: AppStrings.remind,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showEventDetailSheet(BuildContext context, Event event) {
  final theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  event.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _EventInfoRow(
                  icon: Icons.calendar_today,
                  text: DateFormat('EEEE, MMM d, yyyy').format(event.dateTime),
                ),
                const SizedBox(height: 8),
                _EventInfoRow(
                  icon: Icons.access_time,
                  text:
                      '${DateFormat('h:mm a').format(event.dateTime)}${event.endTime != null ? ' - ${DateFormat('h:mm a').format(event.endTime!)}' : ''}',
                ),
                const SizedBox(height: 8),
                _EventInfoRow(
                  icon: Icons.location_on_outlined,
                  text: event.location,
                ),
                const SizedBox(height: 8),
                _EventInfoRow(
                  icon: Icons.people_outline,
                  text: '${event.attendeeCount} attending',
                ),
                const SizedBox(height: 20),
                Text(
                  event.description,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Use the outer context that has access to the BLoC
                      sheetContext.read<EventBloc>().add(
                        ToggleReminder(event.id),
                      );
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            event.isReminded
                                ? 'Reminder removed'
                                : AppStrings.reminderSet,
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: Icon(
                      event.isReminded
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                    ),
                    label: Text(
                      event.isReminded
                          ? AppStrings.reminderSet
                          : AppStrings.setReminder,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _EventInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EventInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
