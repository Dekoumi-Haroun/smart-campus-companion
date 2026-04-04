/// Core Event entity — pure Dart, no Flutter dependency.
///
/// Represents a campus event (workshop, sports match, lecture, etc.).
/// The data layer model will handle JSON serialization to/from this entity.
///
/// Implementation will be completed in Sprint 2 (Networking).
class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime dateTime;
  final String? imageUrl;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    this.imageUrl,
  });
}
