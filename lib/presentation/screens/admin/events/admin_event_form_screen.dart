import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/event.dart';
import '../../../blocs/event/event_bloc.dart';
import '../../../blocs/event/event_event.dart';
import '../../../blocs/event/event_state.dart';

class AdminEventFormScreen extends StatefulWidget {
  final Event? event;

  const AdminEventFormScreen({super.key, this.event});

  @override
  State<AdminEventFormScreen> createState() => _AdminEventFormScreenState();
}

class _AdminEventFormScreenState extends State<AdminEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _attendeeCtrl;
  late String _category;
  late DateTime _dateTime;
  DateTime? _endTime;

  bool get _isEditing => widget.event != null;

  static const _categories = [
    'General',
    'Academic',
    'Workshop',
    'Sports',
    'Career',
    'Social',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _attendeeCtrl = TextEditingController(
      text: e?.attendeeCount != null ? e!.attendeeCount.toString() : '0',
    );
    _category = e?.category.isNotEmpty == true ? e!.category : 'General';
    _dateTime = e?.dateTime ?? DateTime.now().add(const Duration(days: 1));
    _endTime = e?.endTime;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _attendeeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({bool isEnd = false}) async {
    final initial = isEnd ? (_endTime ?? _dateTime) : _dateTime;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isEnd) {
        _endTime = picked;
      } else {
        _dateTime = picked;
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final event = Event(
      id: widget.event?.id ?? 'admin_${now.millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      dateTime: _dateTime,
      endTime: _endTime,
      category: _category,
      attendeeCount: int.tryParse(_attendeeCtrl.text) ?? 0,
    );

    if (_isEditing) {
      context.read<EventBloc>().add(UpdateEvent(event));
    } else {
      context.read<EventBloc>().add(CreateEvent(event));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy  h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editEvent : AppStrings.newEvent),
      ),
      body: BlocListener<EventBloc, EventState>(
        listenWhen: (_, curr) => curr is EventActionSuccess,
        listener: (context, state) {
          if (state is EventActionSuccess) Navigator.pop(context);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _textField(
                  _titleCtrl,
                  AppStrings.titleLabel,
                  validator: _required,
                ),
                const SizedBox(height: 16),
                _textField(
                  _descCtrl,
                  AppStrings.descriptionLabel,
                  maxLines: 4,
                  validator: _required,
                ),
                const SizedBox(height: 16),
                _textField(
                  _locationCtrl,
                  AppStrings.locationLabel,
                  validator: _required,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: AppStrings.categoryLabel,
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 16),
                _textField(
                  _attendeeCtrl,
                  AppStrings.attendeeCountLabel,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Date & Time picker
                _DateTimeTile(
                  label: AppStrings.dateLabel,
                  value: fmt.format(_dateTime),
                  onTap: () => _pickDateTime(),
                ),
                const SizedBox(height: 8),
                _DateTimeTile(
                  label: AppStrings.endDateLabel,
                  value: _endTime != null ? fmt.format(_endTime!) : 'Not set',
                  onTap: () => _pickDateTime(isEnd: true),
                  onClear: _endTime != null
                      ? () => setState(() => _endTime = null)
                      : null,
                ),
                const SizedBox(height: 32),

                FilledButton(
                  onPressed: _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      _isEditing ? 'Update Event' : 'Create Event',
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
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
}

class _DateTimeTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateTimeTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          suffixIcon: onClear != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(value, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}
