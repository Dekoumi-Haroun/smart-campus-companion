import 'package:equatable/equatable.dart';

sealed class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();

  @override
  List<Object?> get props => [];
}

/// Load all announcements from the repository.
class FetchAnnouncements extends AnnouncementEvent {
  const FetchAnnouncements();
}

/// Pull-to-refresh — re-fetches and replaces the list.
class RefreshAnnouncements extends AnnouncementEvent {
  const RefreshAnnouncements();
}

/// Filter announcements by category chip (All / Academic / Sports / General / Urgent).
class FilterByCategory extends AnnouncementEvent {
  final String category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Filter announcements by search query.
class SearchAnnouncements extends AnnouncementEvent {
  final String query;

  const SearchAnnouncements(this.query);

  @override
  List<Object?> get props => [query];
}
