import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../domain/repositories/announcement_repository.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final AnnouncementRepository _repository;

  AnnouncementBloc({required AnnouncementRepository repository})
    : _repository = repository,
      super(const AnnouncementInitial()) {
    on<FetchAnnouncements>(_onFetch);
    on<RefreshAnnouncements>(_onRefresh);
    on<FilterByCategory>(_onFilterByCategory);
    on<SearchAnnouncements>(_onSearch);
  }

  Future<void> _onFetch(
    FetchAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(const AnnouncementLoading());
    try {
      final announcements = await _repository.getAnnouncements();
      emit(AnnouncementLoaded(announcements));
    } on AppException catch (e) {
      emit(AnnouncementError(e.message));
    }
  }

  Future<void> _onRefresh(
    RefreshAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    try {
      final announcements = await _repository.getAnnouncements();
      emit(AnnouncementLoaded(announcements));
    } on AppException catch (e) {
      emit(AnnouncementError(e.message));
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(const AnnouncementLoading());
    try {
      final all = await _repository.getAnnouncements();
      if (event.category.isEmpty || event.category.toLowerCase() == 'all') {
        emit(AnnouncementLoaded(all));
      } else {
        final filtered = all
            .where(
              (a) => a.category.toLowerCase() == event.category.toLowerCase(),
            )
            .toList();
        emit(AnnouncementLoaded(filtered));
      }
    } on AppException catch (e) {
      emit(AnnouncementError(e.message));
    }
  }

  Future<void> _onSearch(
    SearchAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(const AnnouncementLoading());
    try {
      final all = await _repository.getAnnouncements();
      if (event.query.isEmpty) {
        emit(AnnouncementLoaded(all));
      } else {
        final query = event.query.toLowerCase();
        final filtered = all
            .where(
              (a) =>
                  a.title.toLowerCase().contains(query) ||
                  a.body.toLowerCase().contains(query),
            )
            .toList();
        emit(AnnouncementLoaded(filtered));
      }
    } on AppException catch (e) {
      emit(AnnouncementError(e.message));
    }
  }
}
