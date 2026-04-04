import '../../domain/entities/announcement.dart';

/// Data Transfer Object for [Announcement].
///
/// Handles JSON serialization/deserialization. This class lives in the
/// **data** layer and knows about JSON structure. It maps to/from the
/// pure domain [Announcement] entity.
///
/// Will be fully wired to the API response in Sprint 2.
class AnnouncementModel {
  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime date;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.date,
  });

  /// Parse from JSON map (API response).
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      category: json['category'] ?? 'General',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
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
    );
  }
}
