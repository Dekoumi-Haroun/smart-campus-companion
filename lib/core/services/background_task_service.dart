import 'dart:developer' as developer;

import 'package:workmanager/workmanager.dart';

import '../../data/datasources/local/announcement_local_dao.dart';
import '../../data/datasources/local/local_database.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/models/announcement_model.dart';
import 'notification_service.dart';

/// Unique task name for the periodic announcement fetch.
const String backgroundFetchTask = 'com.smartcampus.fetchAnnouncements';

/// Top-level callback required by workmanager.
///
/// This runs in an isolate, so we must re-initialize services.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    developer.log('Background task started: $taskName', name: 'BackgroundTask');

    try {
      if (taskName == backgroundFetchTask ||
          taskName == Workmanager.iOSBackgroundTask) {
        await _fetchAndNotify();
      }
      developer.log(
        'Background task completed: $taskName',
        name: 'BackgroundTask',
      );
      return true;
    } catch (e) {
      developer.log('Background task failed: $e', name: 'BackgroundTask');
      return false;
    }
  });
}

/// Fetches announcements from the API, compares with cached data,
/// and fires a notification if new items are found.
Future<void> _fetchAndNotify() async {
  final localDb = LocalDatabase.instance;
  final dao = AnnouncementLocalDao(localDb);
  final apiClient = ApiClient();

  // Get currently cached count.
  final cachedItems = await dao.getAll();
  final cachedIds = cachedItems.map((m) => m.id).toSet();

  // Fetch fresh data from API.
  try {
    final jsonList = await apiClient.getList('/announcements');
    final freshModels = jsonList
        .map((json) => AnnouncementModel.fromJson(json as Map<String, dynamic>))
        .toList();

    // Cache the new data.
    await dao.insertAll(freshModels);

    // Check for genuinely new items.
    final newItems = freshModels
        .where((m) => !cachedIds.contains(m.id))
        .toList();

    if (newItems.isNotEmpty) {
      // Initialize notification service in the background isolate.
      final notificationService = NotificationService.instance;
      await notificationService.init();

      await notificationService.showInstant(
        title: 'New announcements available',
        body:
            '${newItems.length} new announcement${newItems.length > 1 ? 's' : ''} posted.',
        payload: 'announcements',
      );
      developer.log(
        'Notified user about ${newItems.length} new announcements',
        name: 'BackgroundTask',
      );
    }
  } catch (e) {
    developer.log(
      'Failed to fetch announcements in background: $e',
      name: 'BackgroundTask',
    );
  }
}

/// Service class to register/cancel background tasks.
class BackgroundTaskService {
  BackgroundTaskService._();
  static final BackgroundTaskService instance = BackgroundTaskService._();

  bool _initialized = false;

  /// Initialize workmanager. Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;

    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    _initialized = true;
    developer.log('BackgroundTaskService initialized', name: 'BackgroundTask');
  }

  /// Register the periodic announcement fetch task.
  /// Minimum interval on Android is 15 minutes.
  Future<void> registerPeriodicFetch() async {
    await Workmanager().registerPeriodicTask(
      backgroundFetchTask,
      backgroundFetchTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
    developer.log(
      'Registered periodic fetch task (15min)',
      name: 'BackgroundTask',
    );
  }

  /// Cancel all background tasks (called when user disables notifications).
  Future<void> cancelAll() async {
    await Workmanager().cancelAll();
    developer.log('Cancelled all background tasks', name: 'BackgroundTask');
  }
}
