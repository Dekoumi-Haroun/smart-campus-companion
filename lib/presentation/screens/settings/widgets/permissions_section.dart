import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/feature_permission_service.dart';

/// Permissions card — each row taps open to a descriptive body with a
/// contextual action button (Grant / Revoke / Open Settings / none).
///
/// The widget owns no permission logic of its own: it delegates every
/// state read and every tap to [FeaturePermissionService], which is the
/// single place in the codebase that talks to `permission_handler` and
/// the app-level revocation flags. Side-effects (cancelling scheduled
/// notifications on revoke, re-prompting the OS on grant) are handled
/// inside the service so the UI stays a dumb renderer.
class PermissionsSection extends StatefulWidget {
  final FeaturePermissionService service;

  /// Fired after a grant/revoke so the parent can refresh adjacent UI
  /// (e.g. the Notifications / Bluetooth switches mirror these flags).
  final VoidCallback onChanged;

  const PermissionsSection({
    super.key,
    required this.service,
    required this.onChanged,
  });

  @override
  State<PermissionsSection> createState() => PermissionsSectionState();
}

/// Public state class so the enclosing screen can hold a typed
/// [GlobalKey] and call [refreshExternally] when adjacent UI mutates
/// the same flags the card depends on (Notifications / Bluetooth
/// switches, app resume, …). Kept public deliberately — the class
/// itself has no public API beyond the single refresh hook.
class PermissionsSectionState extends State<PermissionsSection> {
  FeatureKey? _expanded;
  Future<List<FeatureStatus>>? _pending;
  List<FeatureStatus> _statuses = const [];
  FeatureKey? _actionInFlight;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final future = widget.service.snapshot();
    // Block bodies (not arrow) because setState asserts the callback
    // does not return a value — an arrow `() => _pending = future`
    // evaluates to the assigned Future and trips the debug check.
    setState(() {
      _pending = future;
    });
    future.then((s) {
      if (!mounted) return;
      setState(() {
        _statuses = s;
      });
    });
  }

  /// Public hook — the settings screen calls this when it toggles the
  /// Notifications/Bluetooth switches elsewhere, so the corresponding
  /// pill flips without a full screen rebuild.
  void refreshExternally() => _refresh();

  Future<void> _onGrant(FeatureKey key) async {
    setState(() => _actionInFlight = key);
    final result = await widget.service.grant(key);
    if (!mounted) return;
    setState(() => _actionInFlight = null);
    _showActionFeedback(result);
    _refresh();
    widget.onChanged();
  }

  Future<void> _onRevoke(FeatureKey key) async {
    setState(() => _actionInFlight = key);
    await widget.service.revoke(key);
    if (!mounted) return;
    setState(() => _actionInFlight = null);
    _showActionFeedback(FeatureActionResult.revoked);
    _refresh();
    widget.onChanged();
  }

  Future<void> _openSystemSettings() async {
    await widget.service.openSystemSettings();
  }

  void _showActionFeedback(FeatureActionResult result) {
    final messenger = ScaffoldMessenger.of(context);
    final text = switch (result) {
      FeatureActionResult.granted => AppStrings.actionGranted,
      FeatureActionResult.revoked => AppStrings.actionRevoked,
      FeatureActionResult.denied => AppStrings.actionOsDenied,
      FeatureActionResult.permanentlyDenied =>
        AppStrings.permissionPermanentlyDenied,
      FeatureActionResult.notApplicable => '',
    };
    if (text.isEmpty) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: FutureBuilder<List<FeatureStatus>>(
          future: _pending,
          initialData: _statuses,
          builder: (context, snapshot) {
            final rows = snapshot.data ?? const [];
            if (rows.isEmpty) {
              return const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  _ExpandableRow(
                    status: rows[i],
                    expanded: _expanded == rows[i].key,
                    onTap: () => setState(() {
                      _expanded = _expanded == rows[i].key ? null : rows[i].key;
                    }),
                    busy: _actionInFlight == rows[i].key,
                    onGrant: () => _onGrant(rows[i].key),
                    onRevoke: () => _onRevoke(rows[i].key),
                    onOpenSettings: _openSystemSettings,
                  ),
                  if (i != rows.length - 1)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.06),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ROW
// ═══════════════════════════════════════════════════════════════════════════

class _ExpandableRow extends StatelessWidget {
  final FeatureStatus status;
  final bool expanded;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onGrant;
  final VoidCallback onRevoke;
  final VoidCallback onOpenSettings;

  const _ExpandableRow({
    required this.status,
    required this.expanded,
    required this.busy,
    required this.onTap,
    required this.onGrant,
    required this.onRevoke,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = _displayFor(status);
    final color = _colorFor(status.state);

    return InkWell(
      onTap: display.canExpand ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(display.icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              display.label,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusPill(state: status.state),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        display.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (display.canExpand)
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 150),
                    turns: expanded ? 0.5 : 0.0,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12, left: 52),
                child: _ExpandedBody(
                  status: status,
                  busy: busy,
                  onGrant: onGrant,
                  onRevoke: onRevoke,
                  onOpenSettings: onOpenSettings,
                ),
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXPANDED BODY
// ═══════════════════════════════════════════════════════════════════════════

class _ExpandedBody extends StatelessWidget {
  final FeatureStatus status;
  final bool busy;
  final VoidCallback onGrant;
  final VoidCallback onRevoke;
  final VoidCallback onOpenSettings;

  const _ExpandedBody({
    required this.status,
    required this.busy,
    required this.onGrant,
    required this.onRevoke,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final action = _actionFor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            action.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              height: 1.4,
            ),
          ),
          if (action.button != _ActionButtonKind.none) ...[
            const SizedBox(height: 10),
            _ActionButton(
              kind: action.button,
              busy: busy,
              onRevoke: onRevoke,
              onGrant: onGrant,
              onOpenSettings: onOpenSettings,
            ),
          ],
        ],
      ),
    );
  }
}

enum _ActionButtonKind { none, grant, revoke, openSettings }

class _ActionSpec {
  final String body;
  final _ActionButtonKind button;
  const _ActionSpec(this.body, this.button);
}

_ActionSpec _actionFor(FeatureStatus status) {
  return switch (status.state) {
    FeatureState.granted =>
      const _ActionSpec(AppStrings.revokedActiveBody, _ActionButtonKind.revoke),
    FeatureState.revokedByApp =>
      const _ActionSpec(AppStrings.revokedByAppBody, _ActionButtonKind.grant),
    FeatureState.denied =>
      const _ActionSpec(AppStrings.deniedBody, _ActionButtonKind.grant),
    FeatureState.notRequested =>
      const _ActionSpec(AppStrings.deniedBody, _ActionButtonKind.grant),
    FeatureState.permanentlyDenied => const _ActionSpec(
      AppStrings.permanentlyDeniedBody,
      _ActionButtonKind.openSettings,
    ),
    FeatureState.restricted => const _ActionSpec(
      AppStrings.permanentlyDeniedBody,
      _ActionButtonKind.openSettings,
    ),
    FeatureState.auto =>
      const _ActionSpec(AppStrings.autoBody, _ActionButtonKind.none),
  };
}

class _ActionButton extends StatelessWidget {
  final _ActionButtonKind kind;
  final bool busy;
  final VoidCallback onRevoke;
  final VoidCallback onGrant;
  final VoidCallback onOpenSettings;

  const _ActionButton({
    required this.kind,
    required this.busy,
    required this.onRevoke,
    required this.onGrant,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final child = busy
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(_label);

    final style = switch (kind) {
      _ActionButtonKind.revoke => OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      _ActionButtonKind.grant => FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      _ActionButtonKind.openSettings => OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      _ActionButtonKind.none => null,
    };

    final handler = busy ? null : _handler;
    if (kind == _ActionButtonKind.grant) {
      return FilledButton(onPressed: handler, style: style, child: child);
    }
    return OutlinedButton(onPressed: handler, style: style, child: child);
  }

  VoidCallback get _handler {
    return switch (kind) {
      _ActionButtonKind.revoke => onRevoke,
      _ActionButtonKind.grant => onGrant,
      _ActionButtonKind.openSettings => onOpenSettings,
      _ActionButtonKind.none => () {},
    };
  }

  String get _label {
    return switch (kind) {
      _ActionButtonKind.revoke => AppStrings.revokePermission,
      _ActionButtonKind.grant => AppStrings.grantPermission,
      _ActionButtonKind.openSettings => AppStrings.openSettings,
      _ActionButtonKind.none => '',
    };
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STATUS PILL
// ═══════════════════════════════════════════════════════════════════════════

class _StatusPill extends StatelessWidget {
  final FeatureState state;
  const _StatusPill({required this.state});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(state);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _labelFor(state),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DISPLAY METADATA (label / icon / subtitle per feature)
// ═══════════════════════════════════════════════════════════════════════════

class _RowDisplay {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool canExpand;

  const _RowDisplay({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.canExpand = true,
  });
}

_RowDisplay _displayFor(FeatureStatus status) {
  return switch (status.key) {
    FeatureKey.location => const _RowDisplay(
      icon: Icons.location_on_outlined,
      label: AppStrings.permLocationLabel,
      subtitle: AppStrings.permLocationSubtitle,
    ),
    FeatureKey.camera => const _RowDisplay(
      icon: Icons.camera_alt_outlined,
      label: AppStrings.permCameraLabel,
      subtitle: AppStrings.permCameraSubtitle,
    ),
    FeatureKey.notifications => const _RowDisplay(
      icon: Icons.notifications_none_rounded,
      label: AppStrings.permNotificationsLabel,
      subtitle: AppStrings.permNotificationsSubtitle,
    ),
    // Sensors can't be granted or revoked — collapse the row so the
    // user doesn't get a no-op expander.
    FeatureKey.sensors => const _RowDisplay(
      icon: Icons.phone_android_rounded,
      label: AppStrings.permSensorsLabel,
      subtitle: AppStrings.permSensorsSubtitle,
      canExpand: false,
    ),
    FeatureKey.bluetooth => const _RowDisplay(
      icon: Icons.bluetooth_rounded,
      label: AppStrings.permBluetoothLabel,
      subtitle: AppStrings.permBluetoothSubtitle,
    ),
  };
}

Color _colorFor(FeatureState state) {
  return switch (state) {
    FeatureState.granted => AppColors.success,
    FeatureState.auto => AppColors.info,
    FeatureState.notRequested => AppColors.warning,
    FeatureState.denied => AppColors.warning,
    FeatureState.restricted => AppColors.warning,
    FeatureState.revokedByApp => AppColors.error,
    FeatureState.permanentlyDenied => AppColors.error,
  };
}

String _labelFor(FeatureState state) {
  return switch (state) {
    FeatureState.granted => AppStrings.permStatusGranted,
    FeatureState.auto => AppStrings.permStatusAuto,
    FeatureState.notRequested => AppStrings.permStatusNotRequested,
    FeatureState.denied => AppStrings.permStatusDenied,
    FeatureState.restricted => AppStrings.permStatusRestricted,
    FeatureState.revokedByApp => AppStrings.permStatusRevokedInApp,
    FeatureState.permanentlyDenied => AppStrings.permStatusPermanentlyDenied,
  };
}
