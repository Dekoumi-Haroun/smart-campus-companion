import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/data/models/timetable_item_model.dart';

void main() {
  group('TimetableItemModel.fromJson', () {
    test('parses valid JSON correctly', () {
      final json = {
        'id': 't1',
        'courseName': 'Mobile Dev',
        'instructor': 'Dr. Smith',
        'room': 'B201',
        'dayOfWeek': 1,
        'startTime': '09:00',
        'endTime': '10:30',
        'status': 'In Progress',
      };

      final model = TimetableItemModel.fromJson(json);

      expect(model.id, 't1');
      expect(model.courseName, 'Mobile Dev');
      expect(model.instructor, 'Dr. Smith');
      expect(model.room, 'B201');
      expect(model.dayOfWeek, 1);
      expect(model.startTime, '09:00');
      expect(model.endTime, '10:30');
      expect(model.status, 'In Progress');
    });

    test('handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final model = TimetableItemModel.fromJson(json);

      expect(model.id, '');
      expect(model.courseName, '');
      expect(model.instructor, '');
      expect(model.room, '');
      expect(model.dayOfWeek, 1);
      expect(model.startTime, '');
      expect(model.endTime, '');
      expect(model.status, 'Upcoming');
    });

    test('handles null values gracefully', () {
      final json = <String, dynamic>{
        'id': null,
        'courseName': null,
        'instructor': null,
        'room': null,
        'dayOfWeek': null,
        'startTime': null,
        'endTime': null,
        'status': null,
      };

      final model = TimetableItemModel.fromJson(json);

      expect(model.id, '');
      expect(model.courseName, '');
      expect(model.dayOfWeek, 1);
      expect(model.status, 'Upcoming');
    });

    test('handles integer id via toString()', () {
      final json = <String, dynamic>{
        'id': 42,
        'courseName': 'Test',
        'instructor': 'Prof',
        'room': 'A1',
        'dayOfWeek': 3,
        'startTime': '08:00',
        'endTime': '09:30',
      };

      final model = TimetableItemModel.fromJson(json);
      expect(model.id, '42');
    });

    test('toJson round-trips correctly', () {
      const original = TimetableItemModel(
        id: 't5',
        courseName: 'Algorithms',
        instructor: 'Prof. Lee',
        room: 'C302',
        dayOfWeek: 4,
        startTime: '14:00',
        endTime: '15:30',
        status: 'Completed',
      );

      final json = original.toJson();
      final restored = TimetableItemModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.courseName, original.courseName);
      expect(restored.instructor, original.instructor);
      expect(restored.room, original.room);
      expect(restored.dayOfWeek, original.dayOfWeek);
      expect(restored.startTime, original.startTime);
      expect(restored.endTime, original.endTime);
      expect(restored.status, original.status);
    });

    test('toEntity and fromEntity are symmetrical', () {
      const model = TimetableItemModel(
        id: 't1',
        courseName: 'DB',
        instructor: 'Dr. X',
        room: 'D1',
        dayOfWeek: 2,
        startTime: '10:00',
        endTime: '11:30',
      );

      final entity = model.toEntity();
      final back = TimetableItemModel.fromEntity(entity);

      expect(back.id, model.id);
      expect(back.courseName, model.courseName);
      expect(back.dayOfWeek, model.dayOfWeek);
    });
  });
}
