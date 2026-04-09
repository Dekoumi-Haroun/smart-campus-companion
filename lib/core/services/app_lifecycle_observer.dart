import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';

import '../../presentation/blocs/announcement/announcement_bloc.dart';
import '../../presentation/blocs/announcement/announcement_event.dart';

/// Observes app lifecycle transitions and reacts accordingly.
///
/// - **resumed**: refreshes data if stale (> 5 minutes since last fetch).
/// - **paused**: logs the transition (state saving would go here).
/// - All transitions are logged for the Sprint 5 report.
class AppLifecycleObserver extends WidgetsBindingObserver {
  final AnnouncementBloc _announcementBloc;

  DateTime _lastFetchTime = DateTime.now();

  /// How long before we consider data stale.
  static const _staleThreshold = Duration(minutes: 5);

  AppLifecycleObserver({required AnnouncementBloc announcementBloc})
    : _announcementBloc = announcementBloc;

  /// Call this after the initial data fetch to set the baseline.
  void markDataFresh() {
    _lastFetchTime = DateTime.now();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    developer.log('App lifecycle → ${state.name}', name: 'Lifecycle');

    switch (state) {
      case AppLifecycleState.resumed:
        _onResumed();
      case AppLifecycleState.paused:
        _onPaused();
      case AppLifecycleState.inactive:
        developer.log('App inactive (transitioning)', name: 'Lifecycle');
      case AppLifecycleState.detached:
        developer.log('App detached from engine', name: 'Lifecycle');
      case AppLifecycleState.hidden:
        developer.log('App hidden', name: 'Lifecycle');
    }
  }

  void _onResumed() {
    final elapsed = DateTime.now().difference(_lastFetchTime);
    if (elapsed > _staleThreshold) {
      developer.log(
        'Data is stale (${elapsed.inMinutes}min), refreshing announcements',
        name: 'Lifecycle',
      );
      _announcementBloc.add(const RefreshAnnouncements());
      _lastFetchTime = DateTime.now();
    } else {
      developer.log(
        'Data is fresh (${elapsed.inSeconds}s old), skipping refresh',
        name: 'Lifecycle',
      );
    }
  }

  void _onPaused() {
    developer.log('App paused — saving state checkpoint', name: 'Lifecycle');
    // Any unsaved state would be persisted here.
    // Currently the app auto-persists via repositories, so nothing extra needed.
  }

  /// Remove this observer from the binding.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    developer.log('AppLifecycleObserver disposed', name: 'Lifecycle');
  }
}
