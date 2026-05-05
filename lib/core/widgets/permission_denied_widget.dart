import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../services/permission_service.dart';

/// A reusable widget displayed when a required permission is denied.
///
/// Shows:
/// 1. A large icon illustrating the locked feature.
/// 2. A customizable explanation of *why* the permission is needed.
/// 3. An "Open Settings" button when the denial is permanent.
///
/// Used by camera, location, and Bluetooth features to provide
/// a consistent, friendly denial UX across the app.
class PermissionDeniedWidget extends StatelessWidget {
  /// Icon representing the denied feature (e.g. camera, location).
  final IconData icon;

  /// Human-readable reason why the permission is needed.
  final String message;

  /// Whether the permission was permanently denied.
  /// When `true`, shows the "Open Settings" button.
  final bool isPermanentlyDenied;

  /// Optional callback invoked when the user taps "Retry".
  /// Shown only when [isPermanentlyDenied] is `false`.
  final VoidCallback? onRetry;

  /// Overridable [PermissionService] for opening settings.
  final PermissionService _permissionService;

  const PermissionDeniedWidget({
    super.key,
    required this.icon,
    required this.message,
    this.isPermanentlyDenied = false,
    this.onRetry,
    PermissionService permissionService = const PermissionService(),
  }) : _permissionService = permissionService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: theme.colorScheme.error.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),

            // ── Title ──
            Text(
              AppStrings.permissionDeniedTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // ── Explanation ──
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // ── Permanent denial hint ──
            if (isPermanentlyDenied)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  AppStrings.permissionPermanentlyDenied,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 16),

            // ── Action button ──
            if (isPermanentlyDenied)
              ElevatedButton.icon(
                onPressed: () => _permissionService.openSettings(),
                icon: const Icon(Icons.settings_rounded),
                label: const Text(AppStrings.openSettings),
              )
            else if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(AppStrings.retry),
              ),
          ],
        ),
      ),
    );
  }
}
