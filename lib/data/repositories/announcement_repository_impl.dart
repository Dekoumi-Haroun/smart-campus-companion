import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';

/// Concrete implementation of [AnnouncementRepository].
///
/// This class coordinates between the remote API and local cache
/// following the offline-first strategy:
///
/// 1. Try fetching from remote API.
/// 2. On success → cache data locally → return fresh data.
/// 3. On failure (no network) → return cached data from local DB.
/// 4. If no cache exists → throw an exception.
///
/// Will be implemented in Sprint 2 (remote) + Sprint 3 (local caching).

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  // final ApiClient _remoteSource;     // Sprint 2
  // final LocalDatabase _localSource;  // Sprint 3

  @override
  Future<List<Announcement>> getAnnouncements() async {
    // TODO: Sprint 2 — Implement remote fetch + Sprint 3 cache fallback
    throw UnimplementedError('Will be implemented in Sprint 2');
  }

  @override
  Future<Announcement?> getAnnouncementById(String id) async {
    // TODO: Sprint 2 — Implement
    throw UnimplementedError('Will be implemented in Sprint 2');
  }
}
