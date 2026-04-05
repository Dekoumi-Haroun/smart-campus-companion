import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../domain/entities/announcement.dart';
import '../../blocs/announcement/announcement_bloc.dart';
import '../../blocs/announcement/announcement_event.dart';
import '../../blocs/announcement/announcement_state.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = AppStrings.filterAll;

  static const _categories = [
    AppStrings.filterAll,
    AppStrings.filterAcademic,
    AppStrings.filterSports,
    AppStrings.filterGeneral,
    AppStrings.filterUrgent,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Reset category when searching
    setState(() => _selectedCategory = AppStrings.filterAll);
    context.read<AnnouncementBloc>().add(SearchAnnouncements(query));
  }

  void _onCategorySelected(String category) {
    // Clear search when filtering by category
    _searchController.clear();
    setState(() => _selectedCategory = category);
    context.read<AnnouncementBloc>().add(FilterByCategory(category));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.announcementsTitle)),
      body: Column(
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: AppStrings.searchAnnouncements,
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

          // ── Category Filter Chips ──
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => _onCategorySelected(cat),
                  selectedColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.15),
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // ── Announcement List ──
          Expanded(
            child: BlocBuilder<AnnouncementBloc, AnnouncementState>(
              builder: (context, state) {
                if (state is AnnouncementLoading) {
                  return const LoadingWidget();
                }
                if (state is AnnouncementError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () => context.read<AnnouncementBloc>().add(
                      const FetchAnnouncements(),
                    ),
                  );
                }
                if (state is AnnouncementLoaded) {
                  if (state.announcements.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.campaign_outlined,
                      message: AppStrings.noAnnouncements,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AnnouncementBloc>().add(
                        const RefreshAnnouncements(),
                      );
                      // Wait for the next state emission
                      await context.read<AnnouncementBloc>().stream.firstWhere(
                        (s) => s is! AnnouncementLoading,
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: state.announcements.length,
                      itemBuilder: (context, index) {
                        final announcement = state.announcements[index];
                        return _AnnouncementCard(
                          announcement: announcement,
                          onTap: () =>
                              _showAnnouncementDetail(context, announcement),
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
}

// ═══════════════════════════════════════════════════════════════════
// ANNOUNCEMENT CARD
// ═══════════════════════════════════════════════════════════════════

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;

  const _AnnouncementCard({required this.announcement, required this.onTap});

  static Color _categoryColor(String category) {
    return switch (category.toLowerCase()) {
      'academic' => AppColors.tagAcademic,
      'sports' => AppColors.tagSports,
      'urgent' => AppColors.tagUrgent,
      _ => AppColors.tagGeneral,
    };
  }

  static IconData _categoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'academic' => Icons.school_rounded,
      'sports' => Icons.sports_rounded,
      'urgent' => Icons.warning_rounded,
      _ => Icons.info_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _categoryColor(announcement.category);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 4)),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Category tag + bookmark ──
              Row(
                children: [
                  Icon(
                    _categoryIcon(announcement.category),
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                  const Spacer(),
                  Icon(
                    announcement.isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 20,
                    color: announcement.isBookmarked
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Title ──
              Text(
                announcement.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),

              // ── Body preview ──
              Text(
                announcement.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 10),

              // ── Date + read time ──
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(announcement.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  if (announcement.readTime > 0) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.45,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${announcement.readTime} ${AppStrings.minRead}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ANNOUNCEMENT DETAIL BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════

void _showAnnouncementDetail(BuildContext context, Announcement announcement) {
  final theme = Theme.of(context);
  final color = _categoryColorStatic(announcement.category);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.75,
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

                // ── Category tag ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    announcement.category,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Title ──
                Text(
                  announcement.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                // ── Date + source ──
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
                    if (announcement.source.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.source_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          announcement.source,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (announcement.readTime > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${announcement.readTime} ${AppStrings.minRead}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // ── Full body ──
                Text(
                  announcement.body,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                ),
                const SizedBox(height: 28),

                // ── Action bar ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _DetailAction(
                      icon: Icons.share_rounded,
                      label: AppStrings.share,
                      onTap: () => Navigator.pop(context),
                    ),
                    _DetailAction(
                      icon: Icons.bookmark_border_rounded,
                      label: AppStrings.save,
                      onTap: () => Navigator.pop(context),
                    ),
                    _DetailAction(
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

Color _categoryColorStatic(String category) {
  return switch (category.toLowerCase()) {
    'academic' => AppColors.tagAcademic,
    'sports' => AppColors.tagSports,
    'urgent' => AppColors.tagUrgent,
    _ => AppColors.tagGeneral,
  };
}

class _DetailAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DetailAction({
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
