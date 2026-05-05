import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

void showCampusSafetySheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => const _CampusSafetySheet(),
  );
}

class _SafetyContact {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String number;

  const _SafetyContact({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.number,
  });
}

class _CampusSafetySheet extends StatelessWidget {
  const _CampusSafetySheet();

  static const List<_SafetyContact> _contacts = [
    _SafetyContact(
      icon: Icons.shield_rounded,
      iconColor: AppColors.primary,
      label: AppStrings.safetyContactSecurity,
      number: AppStrings.safetyNumberSecurity,
    ),
    _SafetyContact(
      icon: Icons.groups_rounded,
      iconColor: AppColors.success,
      label: AppStrings.safetyContactMedical,
      number: AppStrings.safetyNumberMedical,
    ),
    _SafetyContact(
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.error,
      label: AppStrings.safetyContactFire,
      number: AppStrings.safetyNumberFire,
    ),
  ];

  Future<void> _callSecurity(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final uri = Uri(scheme: 'tel', path: AppStrings.safetyNumberSecurity);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(AppStrings.callFailedMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < _contacts.length; i++) ...[
                _ContactRow(contact: _contacts[i]),
                if (i != _contacts.length - 1)
                  Divider(
                    height: 1,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _callSecurity(context),
                  icon: const Icon(Icons.phone_rounded),
                  label: const Text(
                    AppStrings.callSecurityNow,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.onError,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ),
                ),
                child: const Text(
                  AppStrings.close,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final _SafetyContact contact;

  const _ContactRow({required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(contact.icon, color: contact.iconColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              contact.label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            contact.number,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
