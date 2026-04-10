import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/data/models/event_model.dart';

void main() {
  group('EventModel.fromJson', () {
    test('parses valid JSON correctly', () {
      final json = {
        'id': 'e1',
        'title': 'Open Day',
        'description': 'Visit campus',
        'location': 'Main Gate',
        'dateTime': '2026-05-01T10:00:00.000',
        'imageUrl': 'https://example.com/img.jpg',
        'endTime': '2026-05-01T16:00:00.000',
        'category': 'General',
        'attendeeCount': 120,
        'isReminded': true,
      };

      final model = EventModel.fromJson(json);

      expect(model.id, 'e1');
      expect(model.title, 'Open Day');
      expect(model.description, 'Visit campus');
      expect(model.location, 'Main Gate');
      expect(model.dateTime, DateTime(2026, 5, 1, 10));
      expect(model.imageUrl, 'https://example.com/img.jpg');
      expect(model.endTime, DateTime(2026, 5, 1, 16));
      expect(model.category, 'General');
      expect(model.attendeeCount, 120);
      expect(model.isReminded, true);
    });

    test('handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final model = EventModel.fromJson(json);

      expect(model.id, '');
      expect(model.title, '');
      expect(model.description, '');
      expect(model.location, '');
      expect(model.imageUrl, isNull);
      expect(model.endTime, isNull);
      expect(model.category, '');
      expect(model.attendeeCount, 0);
      expect(model.isReminded, false);
    });

    test('handles null values gracefully', () {
      final json = <String, dynamic>{
        'id': null,
        'title': null,
        'description': null,
        'location': null,
        'dateTime': null,
        'imageUrl': null,
        'endTime': null,
        'category': null,
        'attendeeCount': null,
        'isReminded': null,
      };

      final model = EventModel.fromJson(json);

      expect(model.id, '');
      expect(model.title, '');
      expect(model.imageUrl, isNull);
      expect(model.endTime, isNull);
      expect(model.attendeeCount, 0);
      expect(model.isReminded, false);
    });

    test('handles integer id via toString()', () {
      final json = <String, dynamic>{
        'id': 99,
        'title': 'Test',
        'description': 'Desc',
        'location': 'Here',
        'dateTime': '2026-01-01T00:00:00.000',
      };

      final model = EventModel.fromJson(json);
      expect(model.id, '99');
    });

    test('toJson round-trips correctly', () {
      final original = EventModel(
        id: 'e5',
        title: 'Workshop',
        description: 'Learn Flutter',
        location: 'Lab A',
        dateTime: DateTime(2026, 3, 15, 14, 30),
        imageUrl: 'https://img.com/flutter.png',
        endTime: DateTime(2026, 3, 15, 17),
        category: 'Tech',
        attendeeCount: 50,
        isReminded: true,
      );

      final json = original.toJson();
      final restored = EventModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.location, original.location);
      expect(restored.category, original.category);
      expect(restored.attendeeCount, original.attendeeCount);
      expect(restored.isReminded, original.isReminded);
    });

    test('toEntity and fromEntity are symmetrical', () {
      final model = EventModel(
        id: 'e1',
        title: 'Test',
        description: 'Desc',
        location: 'Loc',
        dateTime: DateTime(2026, 1, 1),
        category: 'Sports',
        attendeeCount: 10,
      );

      final entity = model.toEntity();
      final back = EventModel.fromEntity(entity);

      expect(back.id, model.id);
      expect(back.title, model.title);
      expect(back.category, model.category);
    });
  });
}
