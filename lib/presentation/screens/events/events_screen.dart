import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Events screen.
///
/// Shows upcoming campus events in card format with date, time, and location.
/// Real data from API will replace placeholders in Sprint 2.
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data — will be replaced by BLoC + API in Sprint 2
    final events = [
      _EventData(
        title: 'AI & Machine Learning Workshop',
        date: 'Apr 5, 2026',
        time: '10:00 AM – 12:30 PM',
        location: 'CS Building, Room 204',
        icon: Icons.smart_toy_rounded,
        color: AppColors.primary,
      ),
      _EventData(
        title: 'Spring Career Fair',
        date: 'Apr 8, 2026',
        time: '09:00 AM – 4:00 PM',
        location: 'Main Auditorium',
        icon: Icons.work_rounded,
        color: AppColors.secondary,
      ),
      _EventData(
        title: 'Inter-Department Football Match',
        date: 'Apr 10, 2026',
        time: '3:00 PM – 5:00 PM',
        location: 'University Stadium',
        icon: Icons.sports_soccer_rounded,
        color: AppColors.tagSports,
      ),
      _EventData(
        title: 'Guest Lecture: Sustainable Architecture',
        date: 'Apr 12, 2026',
        time: '2:00 PM – 3:30 PM',
        location: 'Engineering Hall, Amphitheater',
        icon: Icons.architecture_rounded,
        color: AppColors.warning,
      ),
      _EventData(
        title: 'Student Club Photography Exhibition',
        date: 'Apr 15, 2026',
        time: 'All Day',
        location: 'Arts Building, Gallery',
        icon: Icons.photo_camera_rounded,
        color: AppColors.tagAcademic,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.eventsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Calendar view',
            onPressed: () {
              // TODO: Add calendar view in a future sprint
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Trigger data refresh via BLoC in Sprint 2
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _EventCard(data: event);
          },
        ),
      ),
    );
  }
}

// ── Data class for placeholder events ──
class _EventData {
  final String title;
  final String date;
  final String time;
  final String location;
  final IconData icon;
  final Color color;

  const _EventData({
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.icon,
    required this.color,
  });
}

// ── Event Card Widget ──
class _EventCard extends StatelessWidget {
  final _EventData data;

  const _EventCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label:
          'Event: ${data.title}, ${data.date}, ${data.time}, at ${data.location}',
      button: true,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Navigate to event detail in a future sprint
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event icon badge — icon pairs with color for accessibility
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    data.icon,
                    color: data.color,
                    size: 26,
                    semanticLabel: data.title,
                  ),
                ),
                const SizedBox(width: 14),

                // Event details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        text: '${data.date}  •  ${data.time}',
                        semanticLabel: 'Date: ${data.date}, Time: ${data.time}',
                      ),
                      const SizedBox(height: 4),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: data.location,
                        semanticLabel: 'Location: ${data.location}',
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  semanticLabel: 'View details',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? semanticLabel;

  const _InfoRow({required this.icon, required this.text, this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? text,
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
