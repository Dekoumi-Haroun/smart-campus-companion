import '../entities/announcement.dart';

abstract class AnnouncementRepository {
  Future<List<Announcement>> getAnnouncements();
  Future<Announcement?> getAnnouncementById(String id);

  // ── Admin CRUD ──
  Future<Announcement> createAnnouncement(Announcement announcement);
  Future<Announcement> updateAnnouncement(Announcement announcement);
  Future<void> deleteAnnouncement(String id);
}
