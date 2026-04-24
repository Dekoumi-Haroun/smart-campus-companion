import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/timetable_item.dart';
import '../../../blocs/connectivity/connectivity_cubit.dart';
import '../../../blocs/connectivity/connectivity_state.dart';
import '../../../blocs/timetable/timetable_bloc.dart';
import '../../../blocs/timetable/timetable_state.dart';
import 'today_schedule_sheet.dart';

class CurrentClassCard extends StatelessWidget {
  const CurrentClassCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, connState) {
        final isOffline = connState is ConnectivityOffline;

        return BlocBuilder<TimetableBloc, TimetableState>(
          builder: (context, state) {
            if (state is TimetableLoading) {
              return _cardShell(
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              );
            }
            if (state is TimetableError) {
              return _cardShell(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }
            if (state is TimetableLoaded) {
              final today = DateTime.now().weekday;
              final todayClasses =
                  state.items.where((i) => i.dayOfWeek == today).toList()
                    ..sort((a, b) => a.startTime.compareTo(b.startTime));

              final currentOrNext = _findCurrentOrNext(todayClasses);
              final completed =
                  todayClasses.where((c) => c.status == 'Completed').length;

              return GestureDetector(
                onTap: () => showTodayScheduleSheet(context, todayClasses),
                child: _cardShell(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: currentOrNext != null
                        ? _buildClassInfo(
                            context,
                            currentOrNext,
                            completed,
                            todayClasses.length,
                            isOffline: isOffline,
                          )
                        : _buildNoClass(),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _cardShell({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  TimetableItem? _findCurrentOrNext(List<TimetableItem> todayClasses) {
    for (final c in todayClasses) {
      if (c.status == 'In Progress') return c;
    }
    for (final c in todayClasses) {
      if (c.status == 'Upcoming') return c;
    }
    return todayClasses.isNotEmpty ? todayClasses.last : null;
  }

  Widget _buildClassInfo(
    BuildContext context,
    TimetableItem item,
    int completed,
    int total, {
    bool isOffline = false,
  }) {
    final isNow = item.status == 'In Progress';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isNow ? AppColors.error : AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isNow ? AppStrings.now : 'NEXT',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),
            Text(
              isOffline ? '--' : '${item.startTime} - ${item.endTime}',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          item.courseName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.person_outline, color: Colors.white54, size: 16),
            const SizedBox(width: 4),
            Text(
              item.instructor,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.room_outlined, color: Colors.white54, size: 16),
            const SizedBox(width: 4),
            Text(
              item.room,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? completed / total : 0,
            minHeight: 6,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isOffline
              ? 'Last synced: 5 min ago'
              : '$completed of $total ${AppStrings.classesCompleted}',
          style: TextStyle(
            color: isOffline ? AppColors.warning : Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildNoClass() {
    return const Column(
      children: [
        Icon(Icons.free_breakfast_rounded, color: Colors.white38, size: 40),
        SizedBox(height: 8),
        Text(
          AppStrings.noClassNow,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }
}
