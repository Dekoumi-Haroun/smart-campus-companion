import 'package:equatable/equatable.dart';

import '../../../domain/entities/announcement.dart';

sealed class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();

  @override
  List<Object?> get props => [];
}

class FetchAnnouncements extends AnnouncementEvent {
  const FetchAnnouncements();
}

class RefreshAnnouncements extends AnnouncementEvent {
  const RefreshAnnouncements();
}

class FilterByCategory extends AnnouncementEvent {
  final String category;
  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchAnnouncements extends AnnouncementEvent {
  final String query;
  const SearchAnnouncements(this.query);

  @override
  List<Object?> get props => [query];
}

// ── Admin CRUD ──

class CreateAnnouncement extends AnnouncementEvent {
  final Announcement announcement;
  const CreateAnnouncement(this.announcement);

  @override
  List<Object?> get props => [announcement];
}

class UpdateAnnouncement extends AnnouncementEvent {
  final Announcement announcement;
  const UpdateAnnouncement(this.announcement);

  @override
  List<Object?> get props => [announcement];
}

class DeleteAnnouncement extends AnnouncementEvent {
  final String announcementId;
  const DeleteAnnouncement(this.announcementId);

  @override
  List<Object?> get props => [announcementId];
}
