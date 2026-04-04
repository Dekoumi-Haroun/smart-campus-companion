import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Announcements screen.
///
/// Shows a list of campus announcements with category tags.
/// Pull-to-refresh and real API data will be added in Sprint 2.
class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Placeholder data — will be replaced by BLoC + API in Sprint 2
    final announcements = [
      _AnnouncementData(
        title: 'Library Extended Hours During Exams',
        body:
            'The university library will remain open until 11 PM throughout the exam period. Additional study rooms are available on the 3rd floor.',
        date: 'Apr 1, 2026',
        category: 'Academic',
        categoryColor: AppColors.tagAcademic,
      ),
      _AnnouncementData(
        title: 'Campus Wi-Fi Maintenance Notice',
        body:
            'Scheduled network maintenance will take place Saturday from 2-4 AM. Brief interruptions may occur across all buildings.',
        date: 'Mar 30, 2026',
        category: 'General',
        categoryColor: AppColors.tagGeneral,
      ),
      _AnnouncementData(
        title: 'Spring Basketball Tournament',
        body:
            'Registration is now open for the inter-department basketball tournament. Teams of 5 can sign up at the athletics office by Friday.',
        date: 'Mar 28, 2026',
        category: 'Sports',
        categoryColor: AppColors.tagSports,
      ),
      _AnnouncementData(
        title: 'Emergency Drill Scheduled',
        body:
            'A campus-wide fire drill will be conducted on Wednesday at 10 AM. Please follow the posted evacuation routes from all buildings.',
        date: 'Mar 27, 2026',
        category: 'Urgent',
        categoryColor: AppColors.tagUrgent,
      ),
      _AnnouncementData(
        title: 'New Cafeteria Menu Launch',
        body:
            'The campus cafeteria introduces a new healthy menu starting next Monday, featuring vegetarian and vegan options.',
        date: 'Mar 25, 2026',
        category: 'General',
        categoryColor: AppColors.tagGeneral,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.announcementsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search announcements',
            onPressed: () {
              // TODO: Implement search in a future sprint
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
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final item = announcements[index];
            return _AnnouncementCard(data: item);
          },
        ),
      ),
    );
  }
}

// ── Data class for placeholder announcements ──
class _AnnouncementData {
  final String title;
  final String body;
  final String date;
  final String category;
  final Color categoryColor;

  const _AnnouncementData({
    required this.title,
    required this.body,
    required this.date,
    required this.category,
    required this.categoryColor,
  });
}

// ── Announcement Card Widget ──
class _AnnouncementCard extends StatelessWidget {
  final _AnnouncementData data;

  const _AnnouncementCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label:
          '${data.category} announcement: ${data.title}, ${data.date}. ${data.body}',
      button: true,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Navigate to announcement detail in a future sprint
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category tag (icon paired with color for accessibility) + date row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _categoryIcon(data.category),
                          size: 14,
                          color: data.categoryColor,
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: data.categoryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data.category,
                            style: TextStyle(
                              color: data.categoryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      data.date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  data.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),

                // Body preview
                Text(
                  data.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Returns an icon for the category so information is not conveyed by color alone.
  static IconData _categoryIcon(String category) {
    return switch (category) {
      'Academic' => Icons.school_rounded,
      'Sports' => Icons.sports_rounded,
      'Urgent' => Icons.warning_rounded,
      _ => Icons.info_rounded,
    };
  }
}
