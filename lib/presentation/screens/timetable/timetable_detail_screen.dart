import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/timetable_item.dart';
import '../../blocs/timetable/timetable_bloc.dart';
import '../../blocs/timetable/timetable_state.dart';

/// Detail screen for a timetable item, reached via notification deep link.
///
/// Receives the timetable item ID via route arguments and looks it up
/// in the current [TimetableBloc] state.
class TimetableDetailScreen extends StatelessWidget {
  final String itemId;

  const TimetableDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Class Details')),
      body: BlocBuilder<TimetableBloc, TimetableState>(
        builder: (context, state) {
          if (state is TimetableLoaded) {
            final item = state.items
                .where((i) => i.id == itemId)
                .cast<TimetableItem?>()
                .firstOrNull;

            if (item == null) {
              return const Center(child: Text('Class not found'));
            }

            return _ClassDetailContent(item: item, theme: theme);
          }
          if (state is TimetableLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text(AppStrings.errorGeneric));
        },
      ),
    );
  }
}

class _ClassDetailContent extends StatelessWidget {
  final TimetableItem item;
  final ThemeData theme;

  const _ClassDetailContent({required this.item, required this.theme});

  static const _days = [
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course name
          Text(
            item.courseName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          // Status chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(item.status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.status,
              style: TextStyle(
                color: _statusColor(item.status),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Detail rows
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Instructor',
            value: item.instructor,
          ),
          const SizedBox(height: 14),
          _InfoRow(icon: Icons.room_outlined, label: 'Room', value: item.room),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Day',
            value: _days[item.dayOfWeek],
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.access_time,
            label: 'Time',
            value: '${item.startTime} - ${item.endTime}',
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'In Progress' => Colors.red,
      'Completed' => Colors.green,
      _ => Colors.blue,
    };
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
