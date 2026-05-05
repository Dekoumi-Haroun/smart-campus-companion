import '../../domain/entities/timetable_item.dart';

/// Data Transfer Object for [TimetableItem].
///
/// Handles JSON serialization/deserialization. Used for both
/// API communication and local database storage.
class TimetableItemModel {
  final String id;
  final String courseName;
  final String instructor;
  final String room;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String status;

  const TimetableItemModel({
    required this.id,
    required this.courseName,
    required this.instructor,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.status = 'Upcoming',
  });

  /// Parse from JSON map (API response).
  factory TimetableItemModel.fromJson(Map<String, dynamic> json) {
    return TimetableItemModel(
      id: json['id']?.toString() ?? '',
      courseName: json['courseName']?.toString() ?? '',
      instructor: json['instructor']?.toString() ?? '',
      room: json['room']?.toString() ?? '',
      dayOfWeek: json['dayOfWeek'] is int ? json['dayOfWeek'] as int : 1,
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Upcoming',
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
      'status': status,
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
      status: status,
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
      status: entity.status,
    );
  }
}
