/// Core Announcement entity — pure Dart, no Flutter dependency.
///
/// This lives in the domain layer and represents the business concept
/// of an announcement. The data layer's model (with JSON serialization)
/// will map to/from this entity.
///
/// Implementation will be completed in Sprint 2 (Networking).
class Announcement {
  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime date;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.date,
  });
}
