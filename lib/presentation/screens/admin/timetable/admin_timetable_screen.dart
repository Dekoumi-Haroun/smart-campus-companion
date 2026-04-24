import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/timetable_item.dart';
import '../../../blocs/timetable/timetable_bloc.dart';
import '../../../blocs/timetable/timetable_event.dart';
import '../../../blocs/timetable/timetable_state.dart';
import '../announcements/admin_announcements_screen.dart' show AdminEmptyState;

class AdminTimetableScreen extends StatelessWidget {
  const AdminTimetableScreen({super.key});

  static const _days = [
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
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.manageTimetable)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.adminTimetableForm),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      body: BlocConsumer<TimetableBloc, TimetableState>(
        listenWhen: (_, curr) => curr is TimetableActionSuccess,
        listener: (context, state) {
          if (state is TimetableActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionMessage),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TimetableLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TimetableError) {
            return Center(child: Text(state.message));
          }
          if (state is TimetableLoaded) {
            if (state.items.isEmpty) {
              return AdminEmptyState(
                icon: Icons.schedule_outlined,
                message: 'No classes yet.\nTap + to add one.',
              );
            }
            // Group by day of week for readability.
            final byDay = <int, List<TimetableItem>>{};
            for (final item in state.items) {
              byDay.putIfAbsent(item.dayOfWeek, () => []).add(item);
            }
            final sortedDays = byDay.keys.toList()..sort();

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: sortedDays.length,
              itemBuilder: (context, i) {
                final day = sortedDays[i];
                final items = byDay[day]!
                  ..sort((a, b) => a.startTime.compareTo(b.startTime));
                final dayName = day >= 1 && day <= 7
                    ? _days[day - 1]
                    : 'Day $day';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        dayName,
                        style:
                            Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                      ),
                    ),
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _TimetableTile(item: item),
                        )),
                  ],
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TimetableTile extends StatelessWidget {
  final TimetableItem item;

  const _TimetableTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) =>
          context.read<TimetableBloc>().add(DeleteTimetableItem(item.id)),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                theme.colorScheme.tertiary.withValues(alpha: 0.1),
            child: Text(
              item.startTime,
              style: TextStyle(
                  color: theme.colorScheme.tertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700),
            ),
          ),
          title: Text(
            item.courseName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${item.instructor}  •  ${item.room}  •  '
            '${item.startTime}–${item.endTime}',
            style: theme.textTheme.bodySmall,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.adminTimetableForm,
              arguments: item,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteConfirmTitle),
        content: const Text(AppStrings.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.delete,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
