import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Home Dashboard screen.
///
/// Displays a welcome header, quick-stat cards, and a preview of recent
/// announcements. Real data will replace placeholders in Sprint 2.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          // Profile avatar placeholder — will link to account in Sprint 6
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Tooltip(
              message: 'User profile',
              child: IconButton(
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  child: Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                    semanticLabel: 'User profile',
                  ),
                ),
                onPressed: () {
                  // TODO: Navigate to profile in Sprint 6
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome Header ──
            Text(
              AppStrings.welcomeBack,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Here\'s what\'s happening on campus today.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),

            // ── Quick Stats Row ──
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.schedule_rounded,
                    label: AppStrings.nextClass,
                    value: '09:30 AM',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.campaign_rounded,
                    label: 'Announcements',
                    value: '5 new',
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.event_rounded,
                    label: 'Events',
                    value: '3 today',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Recent Announcements Section ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.recentAnnouncements,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to announcements tab (Sprint 2)
                  },
                  child: const Text(AppStrings.seeAll),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Placeholder announcement cards
            _PlaceholderAnnouncementCard(
              title: 'Library Extended Hours',
              subtitle: 'Open until 11 PM during exam week',
              tag: 'Academic',
              tagColor: AppColors.tagAcademic,
            ),
            _PlaceholderAnnouncementCard(
              title: 'Campus Wi-Fi Maintenance',
              subtitle: 'Scheduled downtime Saturday 2-4 AM',
              tag: 'General',
              tagColor: AppColors.tagGeneral,
            ),
            _PlaceholderAnnouncementCard(
              title: 'Basketball Tournament Registration',
              subtitle: 'Sign up before Friday at the gym',
              tag: 'Sports',
              tagColor: AppColors.tagSports,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private Widgets ──

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 26, semanticLabel: label),
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
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderAnnouncementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;

  const _PlaceholderAnnouncementCard({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$tag announcement: $title. $subtitle',
      button: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(subtitle),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: tagColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
