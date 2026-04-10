import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/data/models/announcement_model.dart';

void main() {
  group('AnnouncementModel.fromJson', () {
    test('parses valid JSON correctly', () {
      final json = {
        'id': '1',
        'title': 'Campus Alert',
        'body': 'Stay safe',
        'category': 'Urgent',
        'date': '2026-04-01T00:00:00.000',
        'summary': 'Short summary',
        'source': 'Admin',
        'readTime': 3,
        'isBookmarked': true,
      };

      final model = AnnouncementModel.fromJson(json);

      expect(model.id, '1');
      expect(model.title, 'Campus Alert');
      expect(model.body, 'Stay safe');
      expect(model.category, 'Urgent');
      expect(model.date, DateTime(2026, 4, 1));
      expect(model.summary, 'Short summary');
      expect(model.source, 'Admin');
      expect(model.readTime, 3);
      expect(model.isBookmarked, true);
    });

    test('handles missing optional fields with defaults', () {
      final json = <String, dynamic>{};

      final model = AnnouncementModel.fromJson(json);

      expect(model.id, '');
      expect(model.title, '');
      expect(model.body, '');
      expect(model.category, 'General'); // Default category
      expect(model.summary, '');
      expect(model.source, '');
      expect(model.readTime, 0);
      expect(model.isBookmarked, false);
    });

    test('handles null values gracefully', () {
      final json = <String, dynamic>{
        'id': null,
        'title': null,
        'body': null,
        'category': null,
        'date': null,
        'summary': null,
        'source': null,
        'readTime': null,
        'isBookmarked': null,
      };

      final model = AnnouncementModel.fromJson(json);

      expect(model.id, '');
      expect(model.title, '');
      expect(model.readTime, 0);
      expect(model.isBookmarked, false);
    });

    test('handles incorrect data types without crashing', () {
      final json = <String, dynamic>{
        'id': 42,
        'title': 123,
        'readTime': 'not a number',
        'isBookmarked': 'yes',
        'date': 'not-a-date',
      };

      final model = AnnouncementModel.fromJson(json);
      expect(model.id, '42');
      expect(model.title, '123'); // toString() converts int to string
      expect(model.readTime, 0); // Non-int falls back to 0
      expect(model.isBookmarked, false); // Non-bool falls back to false
      expect(model.date.year, isPositive); // Invalid date falls back to now
    });

    test('toJson round-trips correctly', () {
      final original = AnnouncementModel(
        id: '5',
        title: 'Test',
        body: 'Body text',
        category: 'Academic',
        date: DateTime(2026, 6, 15),
        summary: 'Summary',
        source: 'Office',
        readTime: 2,
        isBookmarked: true,
      );

      final json = original.toJson();
      final restored = AnnouncementModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.body, original.body);
      expect(restored.category, original.category);
      expect(restored.summary, original.summary);
      expect(restored.source, original.source);
      expect(restored.readTime, original.readTime);
      expect(restored.isBookmarked, original.isBookmarked);
    });

    test('toEntity produces correct domain entity', () {
      final model = AnnouncementModel(
        id: '1',
        title: 'Title',
        body: 'Body',
        category: 'Sports',
        date: DateTime(2026, 1, 1),
        summary: 'Sum',
        source: 'Src',
        readTime: 5,
        isBookmarked: false,
      );

      final entity = model.toEntity();

      expect(entity.id, '1');
      expect(entity.title, 'Title');
      expect(entity.category, 'Sports');
    });
  });
}
