import 'package:equatable/equatable.dart';

import '../../../domain/entities/announcement.dart';

sealed class AnnouncementState extends Equatable {
  const AnnouncementState();

  @override
  List<Object?> get props => [];
}

class AnnouncementInitial extends AnnouncementState {
  const AnnouncementInitial();
}

class AnnouncementLoading extends AnnouncementState {
  const AnnouncementLoading();
}

class AnnouncementLoaded extends AnnouncementState {
  final List<Announcement> announcements;

  const AnnouncementLoaded(this.announcements);

  @override
  List<Object?> get props => [announcements];
}

class AnnouncementError extends AnnouncementState {
  final String message;

  const AnnouncementError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted after a successful admin CRUD operation.
///
/// Extends [AnnouncementLoaded] so all existing [BlocBuilder] checks
/// that test `state is AnnouncementLoaded` continue to work unmodified.
class AnnouncementActionSuccess extends AnnouncementLoaded {
  final String actionMessage;

  const AnnouncementActionSuccess(
    this.actionMessage,
    List<Announcement> announcements,
  ) : super(announcements);

  @override
  List<Object?> get props => [actionMessage, announcements];
}
