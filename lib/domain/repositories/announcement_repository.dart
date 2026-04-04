import '../entities/announcement.dart';

/// Abstract contract for Announcement data access.
///
/// This interface lives in the **domain** layer, meaning it has zero
/// knowledge of APIs, databases, or any specific data source.
///
/// The **data** layer provides a concrete implementation that handles
/// the online/offline logic (fetch from API → cache locally → return cached
/// if offline). This is the core of the Repository Pattern.
///
/// Concrete implementation: Sprint 2 (remote) + Sprint 3 (local).
abstract class AnnouncementRepository {
  /// Fetch all announcements.
  /// If online: fetch from API, cache, and return.
  /// If offline: return cached data.
  Future<List<Announcement>> getAnnouncements();

  /// Fetch a single announcement by [id].
  Future<Announcement?> getAnnouncementById(String id);
}
