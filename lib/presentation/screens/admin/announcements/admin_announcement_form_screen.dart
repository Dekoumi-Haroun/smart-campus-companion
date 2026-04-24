import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/announcement.dart';
import '../../../blocs/announcement/announcement_bloc.dart';
import '../../../blocs/announcement/announcement_event.dart';
import '../../../blocs/announcement/announcement_state.dart';

class AdminAnnouncementFormScreen extends StatefulWidget {
  final Announcement? announcement;

  const AdminAnnouncementFormScreen({super.key, this.announcement});

  @override
  State<AdminAnnouncementFormScreen> createState() =>
      _AdminAnnouncementFormScreenState();
}

class _AdminAnnouncementFormScreenState
    extends State<AdminAnnouncementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _sourceCtrl;
  late final TextEditingController _summaryCtrl;
  late final TextEditingController _readTimeCtrl;
  late String _category;

  bool get _isEditing => widget.announcement != null;

  // Mirrors the filter chips on AnnouncementsScreen — both pull from the
  // canonical list on the domain entity so admin-created categories are
  // always filterable.
  static const _categories = Announcement.categories;

  @override
  void initState() {
    super.initState();
    final a = widget.announcement;
    _titleCtrl = TextEditingController(text: a?.title ?? '');
    _bodyCtrl = TextEditingController(text: a?.body ?? '');
    _sourceCtrl = TextEditingController(text: a?.source ?? '');
    _summaryCtrl = TextEditingController(text: a?.summary ?? '');
    _readTimeCtrl = TextEditingController(
      text: a?.readTime != null ? a!.readTime.toString() : '',
    );
    _category = a?.category ?? 'General';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _sourceCtrl.dispose();
    _summaryCtrl.dispose();
    _readTimeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final announcement = Announcement(
      id: widget.announcement?.id ?? 'admin_${now.millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      body: _bodyCtrl.text.trim(),
      category: _category,
      date: widget.announcement?.date ?? now,
      source: _sourceCtrl.text.trim(),
      summary: _summaryCtrl.text.trim(),
      readTime: int.tryParse(_readTimeCtrl.text) ?? 0,
    );

    if (_isEditing) {
      context.read<AnnouncementBloc>().add(UpdateAnnouncement(announcement));
    } else {
      context.read<AnnouncementBloc>().add(CreateAnnouncement(announcement));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? AppStrings.editAnnouncement : AppStrings.newAnnouncement,
        ),
      ),
      body: BlocListener<AnnouncementBloc, AnnouncementState>(
        listenWhen: (_, curr) => curr is AnnouncementActionSuccess,
        listener: (context, state) {
          if (state is AnnouncementActionSuccess) {
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _titleCtrl,
                  label: AppStrings.titleLabel,
                  maxLines: 1,
                  validator: _required,
                ),
                const SizedBox(height: 16),
                _buildDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _bodyCtrl,
                  label: AppStrings.bodyLabel,
                  maxLines: 6,
                  validator: _required,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _summaryCtrl,
                  label: AppStrings.summaryLabel,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _sourceCtrl,
                  label: AppStrings.sourceLabel,
                  maxLines: 1,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _readTimeCtrl,
                  label: AppStrings.readTimeLabel,
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      _isEditing
                          ? 'Update Announcement'
                          : 'Create Announcement',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
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

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _category,
      decoration: const InputDecoration(
        labelText: AppStrings.categoryLabel,
        border: OutlineInputBorder(),
        filled: true,
      ),
      items: _categories
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (v) => setState(() => _category = v!),
    );
  }

  String? _required(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
    return null;
  }
}
