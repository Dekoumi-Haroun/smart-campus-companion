import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../domain/entities/event.dart';
import '../../blocs/event/event_bloc.dart';
import '../../blocs/event/event_event.dart';
import '../../blocs/event/event_state.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  /// The 14-day window shown in the horizontal date picker.
  late final List<DateTime> _dateRange;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dateRange = List.generate(
      14,
      (i) => DateTime(today.year, today.month, today.day + i),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<EventBloc>().add(SearchEvents(query));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.eventsTitle)),
      body: Column(
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: AppStrings.searchEvents,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Horizontal Date Picker ──
          BlocBuilder<EventBloc, EventState>(
            builder: (context, state) {
              // Collect dates that have events for the dot indicators
              final eventDates = <DateTime>{};
              if (state is EventLoaded) {
                for (final e in state.events) {
                  eventDates.add(
                    DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day),
                  );
                }
              }

              return SizedBox(
                height: 78,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _dateRange.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final date = _dateRange[index];
                    final isSelected = _isSameDay(date, _selectedDate);
                    final hasEvents = eventDates.contains(date);

                    return _DateChip(
                      date: date,
                      isSelected: isSelected,
                      hasEvents: hasEvents,
                      onTap: () => setState(() => _selectedDate = date),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // ── Event List ──
          Expanded(
            child: BlocBuilder<EventBloc, EventState>(
              builder: (context, state) {
                if (state is EventLoading) {
                  return const LoadingWidget();
                }
                if (state is EventError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () =>
                        context.read<EventBloc>().add(const FetchEvents()),
                  );
                }
                if (state is EventLoaded) {
                  // Filter by selected date
                  final filtered = state.events
                      .where((e) => _isSameDay(e.dateTime, _selectedDate))
                      .toList();

                  if (state.events.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.event_outlined,
                      message: AppStrings.noEvents,
                    );
                  }

                  if (filtered.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.event_busy_outlined,
                      message:
                          'No events on ${DateFormat('MMM d').format(_selectedDate)}',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<EventBloc>().add(const RefreshEvents());
                      await context.read<EventBloc>().stream.firstWhere(
                        (s) => s is! EventLoading,
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _EventCard(
                          event: filtered[index],
                          onTap: () =>
                              _showEventDetail(context, filtered[index]),
                          onToggleReminder: () =>
                              _toggleReminder(context, filtered[index]),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleReminder(BuildContext context, Event event) {
    context.read<EventBloc>().add(ToggleReminder(event.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          event.isReminded
              ? '${AppStrings.reminderRemovedFor} ${event.title}'
              : '${AppStrings.reminderSetFor} ${event.title}',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// DATE CHIP
// ═══════════════════════════════════════════════════════════════════

class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool hasEvents;
  final VoidCallback onTap;

  const _DateChip({
    required this.date,
    required this.isSelected,
    required this.hasEvents,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = _isSameDay(date, DateTime.now());

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: isToday && !isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEE').format(date).toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white70
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            // Event dot indicator
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasEvents
                    ? (isSelected ? Colors.white : AppColors.secondary)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// ═══════════════════════════════════════════════════════════════════
// EVENT CARD
// ═══════════════════════════════════════════════════════════════════

class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onToggleReminder;

  const _EventCard({
    required this.event,
    required this.onTap,
    required this.onToggleReminder,
  });

  static IconData _categoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'workshop' => Icons.build_rounded,
      'sports' => Icons.emoji_events_rounded,
      'career' => Icons.work_rounded,
      'social' => Icons.music_note_rounded,
      'academic' => Icons.school_rounded,
      _ => Icons.event_rounded,
    };
  }

  static Color _categoryColor(String category) {
    return switch (category.toLowerCase()) {
      'workshop' => AppColors.primary,
      'sports' => AppColors.tagSports,
      'career' => AppColors.secondary,
      'social' => AppColors.warning,
      'academic' => AppColors.tagAcademic,
      _ => AppColors.info,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _categoryColor(event.category);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Type icon ──
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(event.category),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // ── Details ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      event.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Date badge + time
                    Row(
                      children: [
                        _DateBadge(date: event.dateTime),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _formatTimeRange(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.45,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Attendee count + Remind + Attach Photo
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.45,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.attendeeCount} ${AppStrings.going}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Attach Photo placeholder
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(AppStrings.attachPhotoComingSoon),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                AppStrings.attachPhoto,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Remind toggle
                        _RemindButton(
                          isReminded: event.isReminded,
                          onTap: onToggleReminder,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeRange() {
    final start = DateFormat('h:mm a').format(event.dateTime);
    if (event.endTime != null) {
      final end = DateFormat('h:mm a').format(event.endTime!);
      return '$start - $end';
    }
    return start;
  }
}

// ═══════════════════════════════════════════════════════════════════
// DATE BADGE (compact APR 05 style)
// ═══════════════════════════════════════════════════════════════════

class _DateBadge extends StatelessWidget {
  final DateTime date;

  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        DateFormat('MMM dd').format(date).toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// REMIND BUTTON
// ═══════════════════════════════════════════════════════════════════

class _RemindButton extends StatelessWidget {
  final bool isReminded;
  final VoidCallback onTap;

  const _RemindButton({required this.isReminded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isReminded
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isReminded
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isReminded
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              size: 14,
              color: isReminded
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              isReminded ? AppStrings.reminded : AppStrings.remind,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isReminded
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// EVENT DETAIL BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════

void _showEventDetail(BuildContext outerContext, Event event) {
  final theme = Theme.of(outerContext);

  showModalBottomSheet(
    context: outerContext,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Handle ──
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

                // ── Category chip ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _EventCard._categoryColor(
                      event.category,
                    ).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _EventCard._categoryIcon(event.category),
                        size: 14,
                        color: _EventCard._categoryColor(event.category),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.category,
                        style: TextStyle(
                          color: _EventCard._categoryColor(event.category),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Title ──
                Text(
                  event.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Info rows ──
                _DetailInfoRow(
                  icon: Icons.calendar_today,
                  text: DateFormat('EEEE, MMM d, yyyy').format(event.dateTime),
                ),
                const SizedBox(height: 10),
                _DetailInfoRow(
                  icon: Icons.access_time,
                  text:
                      '${DateFormat('h:mm a').format(event.dateTime)}${event.endTime != null ? ' - ${DateFormat('h:mm a').format(event.endTime!)}' : ''}',
                ),
                const SizedBox(height: 10),
                _DetailInfoRow(
                  icon: Icons.location_on_outlined,
                  text: event.location,
                ),
                const SizedBox(height: 10),
                _DetailInfoRow(
                  icon: Icons.people_outline,
                  text: '${event.attendeeCount} ${AppStrings.going}',
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // ── Description ──
                Text(
                  event.description,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                ),
                const SizedBox(height: 28),

                // ── Set Reminder button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      outerContext.read<EventBloc>().add(
                        ToggleReminder(event.id),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(outerContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            event.isReminded
                                ? '${AppStrings.reminderRemovedFor} ${event.title}'
                                : '${AppStrings.reminderSetFor} ${event.title}',
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
                const SizedBox(height: 12),

                // ── Attach Photo placeholder ──
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(outerContext).showSnackBar(
                        const SnackBar(
                          content: Text(AppStrings.attachPhotoComingSoon),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text(AppStrings.attachPhoto),
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
        },
      );
    },
  );
}

class _DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailInfoRow({required this.icon, required this.text});

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
        const SizedBox(width: 10),
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
