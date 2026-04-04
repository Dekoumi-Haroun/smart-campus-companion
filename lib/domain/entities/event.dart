/// Core Event entity — pure Dart, no Flutter dependency.
///
/// Represents a campus event (workshop, sports match, lecture, etc.).
/// The data layer model will handle JSON serialization to/from this entity.
class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime dateTime;
  final String? imageUrl;
  final DateTime? endTime;
  final String category;
  final int attendeeCount;
  final bool isReminded;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    this.imageUrl,
    this.endTime,
    this.category = '',
    this.attendeeCount = 0,
    this.isReminded = false,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? dateTime,
    String? imageUrl,
    DateTime? endTime,
    String? category,
    int? attendeeCount,
    bool? isReminded,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      imageUrl: imageUrl ?? this.imageUrl,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      attendeeCount: attendeeCount ?? this.attendeeCount,
      isReminded: isReminded ?? this.isReminded,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          location == other.location &&
          dateTime == other.dateTime &&
          imageUrl == other.imageUrl &&
          endTime == other.endTime &&
          category == other.category &&
          attendeeCount == other.attendeeCount &&
          isReminded == other.isReminded;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    location,
    dateTime,
    imageUrl,
    endTime,
    category,
    attendeeCount,
    isReminded,
  );
}
