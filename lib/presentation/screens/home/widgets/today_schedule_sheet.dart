import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/entities/timetable_item.dart';

void showTodayScheduleSheet(
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
                            return ScheduleTile(item: classes[index]);
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

class ScheduleTile extends StatefulWidget {
  final TimetableItem item;

  const ScheduleTile({super.key, required this.item});

  @override
  State<ScheduleTile> createState() => _ScheduleTileState();
}

class _ScheduleTileState extends State<ScheduleTile> {
  bool _reminderSet = false;
  int? _notificationId;

  Color _statusColor() {
    return switch (widget.item.status) {
      'Completed' => AppColors.success,
      'In Progress' => AppColors.warning,
      _ => AppColors.info,
    };
  }

  Future<void> _toggleReminder() async {
    final settingsRepo = RepositoryProvider.of<SettingsRepository>(context);
    if (!settingsRepo.getNotificationsEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.notificationsDisabledMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final notificationService = NotificationService.instance;

    if (_reminderSet && _notificationId != null) {
      await notificationService.cancelReminder(_notificationId!);
      if (mounted) {
        setState(() {
          _reminderSet = false;
          _notificationId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.reminderCancelled),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      final granted = await notificationService.requestPermission();
      if (!granted) return;

      final id = await notificationService.scheduleClassReminder(widget.item);
      if (mounted) {
        setState(() {
          _reminderSet = true;
          _notificationId = id;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.reminderScheduled),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.courseName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.item.startTime} - ${widget.item.endTime}  •  ${widget.item.room}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor().withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.item.status,
                  style: TextStyle(
                    color: _statusColor(),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _toggleReminder,
              icon: Icon(
                _reminderSet
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                size: 16,
              ),
              label: Text(
                _reminderSet ? AppStrings.reminderSet : AppStrings.remindMe,
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                foregroundColor: _reminderSet
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                side: BorderSide(
                  color: _reminderSet
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
