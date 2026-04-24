import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/announcement/announcement_bloc.dart';
import '../../blocs/announcement/announcement_state.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/event/event_bloc.dart';
import '../../blocs/event/event_state.dart';
import '../../blocs/timetable/timetable_bloc.dart';
import '../../blocs/timetable/timetable_state.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminPanel),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final name = state is AuthAuthenticated
                    ? state.user.displayName
                    : 'Admin';
                return Chip(
                  avatar: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Info Banner ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Changes are applied immediately and synced to the local cache.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Entity Cards ──
          BlocBuilder<AnnouncementBloc, AnnouncementState>(
            builder: (context, state) {
              final count = state is AnnouncementLoaded
                  ? state.announcements.length
                  : 0;
              return _EntityCard(
                icon: Icons.campaign_rounded,
                title: 'Announcements',
                count: count,
                color: const Color(0xFF6C63FF),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.adminAnnouncements),
              );
            },
          ),
          const SizedBox(height: 12),

          BlocBuilder<EventBloc, EventState>(
            builder: (context, state) {
              final count = state is EventLoaded ? state.events.length : 0;
              return _EntityCard(
                icon: Icons.event_rounded,
                title: 'Events',
                count: count,
                color: const Color(0xFF43A047),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.adminEvents),
              );
            },
          ),
          const SizedBox(height: 12),

          BlocBuilder<TimetableBloc, TimetableState>(
            builder: (context, state) {
              final count = state is TimetableLoaded ? state.items.length : 0;
              return _EntityCard(
                icon: Icons.schedule_rounded,
                title: 'Timetable',
                count: count,
                color: const Color(0xFFEF6C00),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.adminTimetable),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EntityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _EntityCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$count item${count == 1 ? '' : 's'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
