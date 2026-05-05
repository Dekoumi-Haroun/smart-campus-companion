import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/event.dart';
import '../../../blocs/event/event_bloc.dart';
import '../../../blocs/event/event_event.dart';

void showEventDetailSheet(BuildContext context, Event event) {
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
