import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/cache_metrics_service.dart';

/// Storage & Data card — stacked bar + legend + clear action.
///
/// Uses a [ValueNotifier<int>] refresh counter so the encompassing
/// settings screen can trigger a recompute after events that change
/// the cache (e.g. a successful refetch elsewhere in the app).
class StorageSection extends StatefulWidget {
  final CacheMetricsService service;

  /// Called after the user confirms Clear Cache, so the parent can
  /// trigger refetches on the three data blocs.
  final VoidCallback onCacheCleared;

  const StorageSection({
    super.key,
    required this.service,
    required this.onCacheCleared,
  });

  @override
  State<StorageSection> createState() => _StorageSectionState();
}

class _StorageSectionState extends State<StorageSection> {
  int _refreshTick = 0;
  bool _clearing = false;

  Future<void> _onClearPressed() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.clearCacheConfirmTitle),
        content: const Text(AppStrings.clearCacheConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.clearCache),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _clearing = true);
    try {
      await widget.service.clearAll();
    } finally {
      if (mounted) {
        setState(() {
          _clearing = false;
          _refreshTick++;
        });
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.cacheCleared),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    widget.onCacheCleared();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CacheBreakdown>(
      // The `_refreshTick` in the key forces a new future on cache clear.
      key: ValueKey(_refreshTick),
      future: widget.service.compute(),
      builder: (context, snapshot) {
        final breakdown =
            snapshot.data ?? const CacheBreakdown.empty();
        return _StorageCard(
          breakdown: breakdown,
          clearing: _clearing,
          onClear: _onClearPressed,
        );
      },
    );
  }
}

class _StorageCard extends StatelessWidget {
  final CacheBreakdown breakdown;
  final bool clearing;
  final VoidCallback onClear;

  const _StorageCard({
    required this.breakdown,
    required this.clearing,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final segments = [
      _Segment(
        color: AppColors.success,
        label: AppStrings.cacheAnnouncements,
        bytes: breakdown.announcementsBytes,
      ),
      _Segment(
        color: AppColors.tagAcademic,
        label: AppStrings.cacheEvents,
        bytes: breakdown.eventsBytes,
      ),
      _Segment(
        color: AppColors.info,
        label: AppStrings.cacheTimetable,
        bytes: breakdown.timetableBytes,
      ),
      _Segment(
        color: AppColors.warning,
        label: AppStrings.cacheImages,
        bytes: breakdown.imagesBytes,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StackedBar(segments: segments),
            const SizedBox(height: 14),

            // Legend — two rows × two columns so labels never wrap.
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                for (final s in segments) _LegendDot(segment: s),
              ],
            ),
            const SizedBox(height: 14),

            Text.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  const TextSpan(text: '${AppStrings.totalCached} '),
                  TextSpan(
                    text: formatBytes(breakdown.totalBytes),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' ${AppStrings.ofCachedData}'),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${AppStrings.lastSynced} ${formatRelativeTime(breakdown.lastSynced)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: clearing ? null : onClear,
                icon: clearing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text(AppStrings.clearCache),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment {
  final Color color;
  final String label;
  final int bytes;

  const _Segment({
    required this.color,
    required this.label,
    required this.bytes,
  });
}

/// Proportional stacked bar. Segments with zero bytes are hidden so the
/// bar always adds up; an all-zero cache shows a muted placeholder.
class _StackedBar extends StatelessWidget {
  final List<_Segment> segments;

  const _StackedBar({required this.segments});

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<int>(0, (sum, s) => sum + s.bytes);
    final theme = Theme.of(context);

    if (total == 0) {
      return Container(
        height: 10,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          for (final s in segments)
            if (s.bytes > 0)
              Expanded(
                flex: s.bytes,
                child: Container(height: 10, color: s.color),
              ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final _Segment segment;

  const _LegendDot({required this.segment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: segment.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${segment.label}: ${formatBytes(segment.bytes)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
