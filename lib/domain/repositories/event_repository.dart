import '../entities/event.dart';

/// Abstract contract for Event data access.
///
/// Same pattern as [AnnouncementRepository]: domain defines the contract,
/// data layer implements the online/offline strategy.
///
/// Concrete implementation: Sprint 2 (remote) + Sprint 3 (local).
abstract class EventRepository {
  /// Fetch all events.
  Future<List<Event>> getEvents();

  /// Fetch a single event by [id].
  Future<Event?> getEventById(String id);
}
