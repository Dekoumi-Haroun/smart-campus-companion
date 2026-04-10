import '../../domain/entities/announcement.dart';

/// Data Transfer Object for [Announcement].
///
/// Handles JSON serialization/deserialization. This class lives in the
/// **data** layer and knows about JSON structure. It maps to/from the
/// pure domain [Announcement] entity.
class AnnouncementModel {
  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime date;
  final String summary;
  final String source;
  final int readTime;
  final bool isBookmarked;

  const AnnouncementModel({
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

  /// Parse from JSON map (API response).
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      summary: json['summary']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      readTime: json['readTime'] is int ? json['readTime'] as int : 0,
      isBookmarked: json['isBookmarked'] is bool
          ? json['isBookmarked'] as bool
          : false,
    );
  }

  /// Convert to JSON map (for local caching).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category': category,
      'date': date.toIso8601String(),
      'summary': summary,
      'source': source,
      'readTime': readTime,
      'isBookmarked': isBookmarked,
    };
  }

  /// Convert this model to a domain entity.
  Announcement toEntity() {
    return Announcement(
      id: id,
      title: title,
      body: body,
      category: category,
      date: date,
      summary: summary,
      source: source,
      readTime: readTime,
      isBookmarked: isBookmarked,
    );
  }

  /// Create a model from a domain entity.
  factory AnnouncementModel.fromEntity(Announcement entity) {
    return AnnouncementModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      category: entity.category,
      date: entity.date,
      summary: entity.summary,
      source: entity.source,
      readTime: entity.readTime,
      isBookmarked: entity.isBookmarked,
    );
  }
}
