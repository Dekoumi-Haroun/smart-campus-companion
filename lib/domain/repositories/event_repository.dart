import '../entities/event.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
  Future<Event?> getEventById(String id);

  // ── Admin CRUD ──
  Future<Event> createEvent(Event event);
  Future<Event> updateEvent(Event event);
  Future<void> deleteEvent(String id);
}
