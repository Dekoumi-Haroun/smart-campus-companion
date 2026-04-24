import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/timetable_item.dart';
import '../../../blocs/timetable/timetable_bloc.dart';
import '../../../blocs/timetable/timetable_event.dart';
import '../../../blocs/timetable/timetable_state.dart';

class AdminTimetableFormScreen extends StatefulWidget {
  final TimetableItem? timetableItem;

  const AdminTimetableFormScreen({super.key, this.timetableItem});

  @override
  State<AdminTimetableFormScreen> createState() =>
      _AdminTimetableFormScreenState();
}

class _AdminTimetableFormScreenState extends State<AdminTimetableFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _courseCtrl;
  late final TextEditingController _instructorCtrl;
  late final TextEditingController _roomCtrl;
  late final TextEditingController _startTimeCtrl;
  late final TextEditingController _endTimeCtrl;
  late int _dayOfWeek;
  late String _status;

  bool get _isEditing => widget.timetableItem != null;

  static const _days = [
    (1, 'Monday'),
    (2, 'Tuesday'),
    (3, 'Wednesday'),
    (4, 'Thursday'),
    (5, 'Friday'),
    (6, 'Saturday'),
    (7, 'Sunday'),
  ];

  static const _statuses = ['Upcoming', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    final t = widget.timetableItem;
    _courseCtrl = TextEditingController(text: t?.courseName ?? '');
    _instructorCtrl = TextEditingController(text: t?.instructor ?? '');
    _roomCtrl = TextEditingController(text: t?.room ?? '');
    _startTimeCtrl = TextEditingController(text: t?.startTime ?? '');
    _endTimeCtrl = TextEditingController(text: t?.endTime ?? '');
    _dayOfWeek = t?.dayOfWeek ?? 1;
    _status = t?.status ?? 'Upcoming';
  }

  @override
  void dispose() {
    _courseCtrl.dispose();
    _instructorCtrl.dispose();
    _roomCtrl.dispose();
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final parts = ctrl.text.split(':');
    final initial = parts.length == 2
        ? TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 8,
            minute: int.tryParse(parts[1]) ?? 0,
          )
        : const TimeOfDay(hour: 8, minute: 0);

    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;

    final hh = picked.hour.toString().padLeft(2, '0');
    final mm = picked.minute.toString().padLeft(2, '0');
    setState(() => ctrl.text = '$hh:$mm');
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final timetableItem = TimetableItem(
      id: widget.timetableItem?.id ?? 'admin_${now.millisecondsSinceEpoch}',
      courseName: _courseCtrl.text.trim(),
      instructor: _instructorCtrl.text.trim(),
      room: _roomCtrl.text.trim(),
      dayOfWeek: _dayOfWeek,
      startTime: _startTimeCtrl.text.trim(),
      endTime: _endTimeCtrl.text.trim(),
      status: _status,
    );

    if (_isEditing) {
      context.read<TimetableBloc>().add(UpdateTimetableItem(timetableItem));
    } else {
      context.read<TimetableBloc>().add(CreateTimetableItem(timetableItem));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editClass : AppStrings.newClass),
      ),
      body: BlocListener<TimetableBloc, TimetableState>(
        listenWhen: (_, curr) => curr is TimetableActionSuccess,
        listener: (context, state) {
          if (state is TimetableActionSuccess) Navigator.pop(context);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _textField(_courseCtrl, AppStrings.courseNameLabel,
                    validator: _required),
                const SizedBox(height: 16),
                _textField(_instructorCtrl, AppStrings.instructorLabel,
                    validator: _required),
                const SizedBox(height: 16),
                _textField(_roomCtrl, AppStrings.roomLabel,
                    validator: _required),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _dayOfWeek,
                  decoration: const InputDecoration(
                    labelText: AppStrings.dayOfWeekLabel,
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  items: _days
                      .map((d) => DropdownMenuItem(
                            value: d.$1,
                            child: Text(d.$2),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _dayOfWeek = v!),
                ),
                const SizedBox(height: 16),
                _TimeTile(
                  label: AppStrings.startTimeLabel,
                  controller: _startTimeCtrl,
                  onTap: () => _pickTime(_startTimeCtrl),
                  validator: _requiredTime,
                ),
                const SizedBox(height: 16),
                _TimeTile(
                  label: AppStrings.endTimeLabel,
                  controller: _endTimeCtrl,
                  onTap: () => _pickTime(_endTimeCtrl),
                  validator: _requiredTime,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: AppStrings.statusLabel,
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  items: _statuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      _isEditing ? 'Update Class' : 'Add Class',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController ctrl,
    String label, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
      ),
      validator: validator,
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? AppStrings.fieldRequired : null;

  String? _requiredTime(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
    final parts = v.trim().split(':');
    if (parts.length != 2 ||
        int.tryParse(parts[0]) == null ||
        int.tryParse(parts[1]) == null) {
      return AppStrings.invalidTimeFormat;
    }
    return null;
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final String? Function(String?)? validator;

  const _TimeTile({
    required this.label,
    required this.controller,
    required this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        suffixIcon: const Icon(Icons.access_time_outlined, size: 20),
        hintText: 'HH:MM',
      ),
    );
  }
}
