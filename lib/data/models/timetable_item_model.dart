import '../../domain/entities/timetable_item.dart';

/// Data Transfer Object for [TimetableItem].
///
/// Handles JSON serialization/deserialization. Used for both
/// API communication and local database storage.
///
/// Will be fully wired to the API response in Sprint 2.
class TimetableItemModel {
  final String id;
  final String courseName;
  final String instructor;
  final String room;
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  const TimetableItemModel({
    required this.id,
    required this.courseName,
    required this.instructor,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  /// Parse from JSON map (API response).
  factory TimetableItemModel.fromJson(Map<String, dynamic> json) {
    return TimetableItemModel(
      id: json['id']?.toString() ?? '',
      courseName: json['courseName'] ?? '',
      instructor: json['instructor'] ?? '',
      room: json['room'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? 1,
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }

  /// Convert to JSON map (for local caching and file export).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseName': courseName,
      'instructor': instructor,
      'room': room,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  /// Convert this model to a domain entity.
  TimetableItem toEntity() {
    return TimetableItem(
      id: id,
      courseName: courseName,
      instructor: instructor,
      room: room,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// Create a model from a domain entity.
  factory TimetableItemModel.fromEntity(TimetableItem entity) {
    return TimetableItemModel(
      id: entity.id,
      courseName: entity.courseName,
      instructor: entity.instructor,
      room: entity.room,
      dayOfWeek: entity.dayOfWeek,
      startTime: entity.startTime,
      endTime: entity.endTime,
    );
  }
}
