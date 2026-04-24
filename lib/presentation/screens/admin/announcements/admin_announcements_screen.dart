import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/announcement.dart';
import '../../../blocs/announcement/announcement_bloc.dart';
import '../../../blocs/announcement/announcement_event.dart';
import '../../../blocs/announcement/announcement_state.dart';

class AdminAnnouncementsScreen extends StatelessWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.manageAnnouncements)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.adminAnnouncementForm,
        ),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      body: BlocConsumer<AnnouncementBloc, AnnouncementState>(
        listenWhen: (_, curr) => curr is AnnouncementActionSuccess,
        listener: (context, state) {
          if (state is AnnouncementActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionMessage),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AnnouncementLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AnnouncementError) {
            return Center(child: Text(state.message));
          }
          if (state is AnnouncementLoaded) {
            if (state.announcements.isEmpty) {
              return AdminEmptyState(
                icon: Icons.campaign_outlined,
                message: 'No announcements yet.\nTap + to create one.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: state.announcements.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final a = state.announcements[index];
                return _AnnouncementTile(announcement: a);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final Announcement announcement;

  const _AnnouncementTile({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(announcement.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) {
        context
            .read<AnnouncementBloc>()
            .add(DeleteAnnouncement(announcement.id));
      },
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              announcement.category.isNotEmpty
                  ? announcement.category[0].toUpperCase()
                  : 'A',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            announcement.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${announcement.category}  •  '
            '${DateFormat('MMM d, yyyy').format(announcement.date)}',
            style: theme.textTheme.bodySmall,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.adminAnnouncementForm,
              arguments: announcement,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteConfirmTitle),
        content: const Text(AppStrings.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppStrings.delete,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const AdminEmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
          ),
        ],
      ),
    );
  }
}
