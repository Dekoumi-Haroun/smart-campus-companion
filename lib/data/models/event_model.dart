import '../../domain/entities/event.dart';

/// Data Transfer Object for [Event].
///
/// Handles JSON serialization/deserialization between API responses,
/// local database, and the pure domain [Event] entity.
class EventModel {
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

  const EventModel({
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

  /// Parse from JSON map (API response).
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      dateTime:
          DateTime.tryParse(json['dateTime']?.toString() ?? '') ??
          DateTime.now(),
      imageUrl: json['imageUrl']?.toString(),
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'].toString())
          : null,
      category: json['category']?.toString() ?? '',
      attendeeCount: json['attendeeCount'] is int
          ? json['attendeeCount'] as int
          : 0,
      isReminded: json['isReminded'] is bool
          ? json['isReminded'] as bool
          : false,
    );
  }

  /// Convert to JSON map (for local caching).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'dateTime': dateTime.toIso8601String(),
      'imageUrl': imageUrl,
      'endTime': endTime?.toIso8601String(),
      'category': category,
      'attendeeCount': attendeeCount,
      'isReminded': isReminded,
    };
  }

  /// Convert this model to a domain entity.
  Event toEntity() {
    return Event(
      id: id,
      title: title,
      description: description,
      location: location,
      dateTime: dateTime,
      imageUrl: imageUrl,
      endTime: endTime,
      category: category,
      attendeeCount: attendeeCount,
      isReminded: isReminded,
    );
  }

  /// Create a model from a domain entity.
  factory EventModel.fromEntity(Event entity) {
    return EventModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      location: entity.location,
      dateTime: entity.dateTime,
      imageUrl: entity.imageUrl,
      endTime: entity.endTime,
      category: entity.category,
      attendeeCount: entity.attendeeCount,
      isReminded: entity.isReminded,
    );
  }
}
