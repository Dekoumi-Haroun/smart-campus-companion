import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../blocs/timetable/timetable_bloc.dart';
import '../../../blocs/timetable/timetable_event.dart';
import '../../../blocs/timetable/timetable_state.dart';
import 'campus_safety_sheet.dart';

class BottomActionButtons extends StatefulWidget {
  const BottomActionButtons({super.key});

  @override
  State<BottomActionButtons> createState() => _BottomActionButtonsState();
}

class _BottomActionButtonsState extends State<BottomActionButtons> {
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TimetableBloc, TimetableState>(
      listenWhen: (_, current) =>
          current is TimetableExported ||
          (current is TimetableError && _exporting),
      listener: (context, state) {
        if (state is TimetableExported) {
          setState(() => _exporting = false);
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(
            SnackBar(
              content: Text('Saved to ${state.filePath}'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 8),
            ),
          );
          SharePlus.instance.share(
            ShareParams(
              files: [XFile(state.filePath)],
              subject: 'My Class Schedule',
            ),
          );
        } else if (state is TimetableError) {
          setState(() => _exporting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export failed: ${state.message}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exporting
                    ? null
                    : () {
                        setState(() => _exporting = true);
                        context.read<TimetableBloc>().add(
                          const ExportTimetable(),
                        );
                      },
                icon: _exporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_rounded),
                label: Text(
                  _exporting ? 'Exporting…' : AppStrings.exportSchedule,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => showCampusSafetySheet(context),
                icon: const Icon(Icons.shield_rounded),
                label: const Text(AppStrings.campusSafety),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
