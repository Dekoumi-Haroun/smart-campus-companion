/// Core Announcement entity — pure Dart, no Flutter dependency.
///
/// This lives in the domain layer and represents the business concept
/// of an announcement. The data layer's model (with JSON serialization)
/// will map to/from this entity.
class Announcement {
  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime date;
  final String summary;
  final String source;
  final int readTime;
  final bool isBookmarked;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.date,
    this.summary = '',
    this.source = '',
    this.readTime = 0,
    this.isBookmarked = false,
  });

  Announcement copyWith({
    String? id,
    String? title,
    String? body,
    String? category,
    DateTime? date,
    String? summary,
    String? source,
    int? readTime,
    bool? isBookmarked,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      date: date ?? this.date,
      summary: summary ?? this.summary,
      source: source ?? this.source,
      readTime: readTime ?? this.readTime,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Announcement &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          body == other.body &&
          category == other.category &&
          date == other.date &&
          summary == other.summary &&
          source == other.source &&
          readTime == other.readTime &&
          isBookmarked == other.isBookmarked;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    body,
    category,
    date,
    summary,
    source,
    readTime,
    isBookmarked,
  );
}
