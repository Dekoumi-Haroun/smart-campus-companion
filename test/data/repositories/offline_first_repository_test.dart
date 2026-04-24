import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_campus/core/errors/app_exceptions.dart';
import 'package:smart_campus/data/datasources/local/announcement_local_dao.dart';
import 'package:smart_campus/data/datasources/local/event_local_dao.dart';
import 'package:smart_campus/data/datasources/local/local_database.dart';
import 'package:smart_campus/data/datasources/local/timetable_local_dao.dart';
import 'package:smart_campus/data/datasources/remote/api_client.dart';
import 'package:smart_campus/data/models/announcement_model.dart';
import 'package:smart_campus/data/models/event_model.dart';
import 'package:smart_campus/data/models/timetable_item_model.dart';
import 'package:smart_campus/data/repositories/announcement_repository_impl.dart';
import 'package:smart_campus/data/repositories/event_repository_impl.dart';
import 'package:smart_campus/data/repositories/timetable_repository_impl.dart';
import 'package:smart_campus/domain/entities/announcement.dart';
import 'package:smart_campus/domain/entities/event.dart';
import 'package:smart_campus/domain/entities/timetable_item.dart';

// ---------------------------------------------------------------------------
// Fake ApiClient that simulates network success/failure
// ---------------------------------------------------------------------------
class FakeApiClient extends ApiClient {
  Map<String, List<Map<String, dynamic>>>? responses;
  bool shouldFail = false;

  FakeApiClient() : super();

  @override
  Future<List<dynamic>> getList(String endpoint) async {
    if (shouldFail) {
      throw DioException(
        requestOptions: RequestOptions(path: endpoint),
        type: DioExceptionType.connectionError,
      );
    }
    return responses?[endpoint] ?? [];
  }
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------
final _announcementJson = [
  {
    'id': '1',
    'title': 'Campus Alert',
    'body': 'Stay safe',
    'category': 'Urgent',
    'date': '2026-04-01T00:00:00.000',
    'summary': '',
    'source': '',
    'readTime': 2,
    'isBookmarked': false,
  },
];

final _eventJson = [
  {
    'id': '1',
    'title': 'Open Day',
    'description': 'Come visit',
    'location': 'Main Gate',
    'dateTime': '2026-05-01T10:00:00.000',
    'imageUrl': null,
    'endTime': null,
    'category': 'General',
    'attendeeCount': 100,
    'isReminded': false,
  },
];

final _timetableJson = [
  {
    'id': '1',
    'courseName': 'Mobile Dev',
    'instructor': 'Dr. Smith',
    'room': 'B201',
    'dayOfWeek': 1,
    'startTime': '09:00',
    'endTime': '10:30',
    'status': 'Upcoming',
  },
];

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final localDb = LocalDatabase.instance;
  late FakeApiClient fakeApi;

  setUp(() async {
    fakeApi = FakeApiClient();
    // Clear all tables between tests.
    final db = await localDb.database;
    await db.delete('announcements');
    await db.delete('events');
    await db.delete('timetable_items');
  });

  // =========================================================================
  // Announcement Repository
  // =========================================================================
  group('AnnouncementRepositoryImpl — offline-first', () {
    late AnnouncementRepositoryImpl repo;
    late AnnouncementLocalDao dao;

    setUp(() {
      dao = AnnouncementLocalDao(localDb);
      repo = AnnouncementRepositoryImpl(apiClient: fakeApi, localDao: dao);
    });

    test('online: fetches from API and caches locally', () async {
      fakeApi.responses = {'/announcements': _announcementJson};

      final result = await repo.getAnnouncements();
      expect(result.length, 1);
      expect(result.first.title, 'Campus Alert');

      // Verify it was cached.
      final cached = await dao.getAll();
      expect(cached.length, 1);
    });

    test('offline: returns cached data when API fails', () async {
      // Populate cache via online fetch.
      fakeApi.responses = {'/announcements': _announcementJson};
      await repo.getAnnouncements();

      // Simulate offline.
      fakeApi.shouldFail = true;
      final result = await repo.getAnnouncements();
      expect(result.length, 1);
      expect(result.first.title, 'Campus Alert');
    });

    test('offline + empty cache: throws CacheException', () async {
      fakeApi.shouldFail = true;

      expect(() => repo.getAnnouncements(), throwsA(isA<CacheException>()));
    });
  });

  // =========================================================================
  // Event Repository
  // =========================================================================
  group('EventRepositoryImpl — offline-first', () {
    late EventRepositoryImpl repo;
    late EventLocalDao dao;

    setUp(() {
      dao = EventLocalDao(localDb);
      repo = EventRepositoryImpl(apiClient: fakeApi, localDao: dao);
    });

    test('online: fetches from API and caches locally', () async {
      fakeApi.responses = {'/events': _eventJson};

      final result = await repo.getEvents();
      expect(result.length, 1);
      expect(result.first.title, 'Open Day');

      final cached = await dao.getAll();
      expect(cached.length, 1);
    });

    test('offline: returns cached data when API fails', () async {
      fakeApi.responses = {'/events': _eventJson};
      await repo.getEvents();

      fakeApi.shouldFail = true;
      final result = await repo.getEvents();
      expect(result.length, 1);
      expect(result.first.title, 'Open Day');
    });

    test('offline + empty cache: throws CacheException', () async {
      fakeApi.shouldFail = true;

      expect(() => repo.getEvents(), throwsA(isA<CacheException>()));
    });
  });

  // =========================================================================
  // Timetable Repository
  // =========================================================================
  group('TimetableRepositoryImpl — offline-first', () {
    late TimetableRepositoryImpl repo;
    late TimetableLocalDao dao;

    setUp(() {
      dao = TimetableLocalDao(localDb);
      repo = TimetableRepositoryImpl(apiClient: fakeApi, localDao: dao);
    });

    test('online: fetches from API and caches locally', () async {
      fakeApi.responses = {'/timetable': _timetableJson};

      final result = await repo.getTimetable();
      expect(result.length, 1);
      expect(result.first.courseName, 'Mobile Dev');

      final cached = await dao.getAll();
      expect(cached.length, 1);
    });

    test('offline: returns cached timetable', () async {
      fakeApi.responses = {'/timetable': _timetableJson};
      await repo.getTimetable();

      fakeApi.shouldFail = true;
      final result = await repo.getTimetable();
      expect(result.length, 1);
      expect(result.first.courseName, 'Mobile Dev');
    });

    test('offline + empty cache: throws CacheException', () async {
      fakeApi.shouldFail = true;

      expect(() => repo.getTimetable(), throwsA(isA<CacheException>()));
    });

    test('getTimetableByDay returns filtered cached data offline', () async {
      fakeApi.responses = {'/timetable': _timetableJson};
      await repo.getTimetable(); // Populate cache.

      fakeApi.shouldFail = true;
      final monday = await repo.getTimetableByDay(1);
      expect(monday.length, 1);

      final tuesday = await repo.getTimetableByDay(2);
      expect(tuesday.length, 0);
    });

    test(
      'getTimetableByDay throws CacheException when offline + empty cache',
      () async {
        fakeApi.shouldFail = true;

        expect(() => repo.getTimetableByDay(1), throwsA(isA<CacheException>()));
      },
    );
  });

  // =========================================================================
  // Admin writes survive server sync (regression for the
  // "admin-created entity vanishes on app restart" bug)
  // =========================================================================
  group('Admin writes survive server sync', () {
    test(
      'AnnouncementLocalDao: admin-created row survives subsequent insertAll',
      () async {
        final dao = AnnouncementLocalDao(localDb);

        // Simulate first app launch: server returns mock announcements.
        await dao.insertAll([
          AnnouncementModel.fromJson(_announcementJson.first),
        ]);

        // Admin creates a local announcement.
        final adminAnnouncement = AnnouncementModel.fromEntity(
          Announcement(
            id: 'admin_1',
            title: 'Admin Post',
            body: 'Local only',
            category: 'Academic',
            date: DateTime(2026, 4, 24),
          ),
        );
        await dao.insertOne(adminAnnouncement);

        // Simulate app restart: server sync runs again with the same mocks.
        await dao.insertAll([
          AnnouncementModel.fromJson(_announcementJson.first),
        ]);

        final cached = await dao.getAll();
        expect(cached.length, 2);
        expect(cached.any((a) => a.id == 'admin_1'), isTrue);
        expect(cached.any((a) => a.id == '1'), isTrue);
      },
    );

    test(
      'EventLocalDao: admin-created row survives subsequent insertAll',
      () async {
        final dao = EventLocalDao(localDb);

        await dao.insertAll([EventModel.fromJson(_eventJson.first)]);

        final adminEvent = EventModel.fromEntity(
          Event(
            id: 'admin_e1',
            title: 'Admin Event',
            description: 'Local only',
            location: 'Test Hall',
            dateTime: DateTime(2026, 5, 1),
            category: 'Workshop',
          ),
        );
        await dao.insertOne(adminEvent);

        await dao.insertAll([EventModel.fromJson(_eventJson.first)]);

        final cached = await dao.getAll();
        expect(cached.length, 2);
        expect(cached.any((e) => e.id == 'admin_e1'), isTrue);
      },
    );

    test(
      'TimetableLocalDao: admin-created row survives subsequent insertAll',
      () async {
        final dao = TimetableLocalDao(localDb);

        await dao.insertAll([
          TimetableItemModel.fromJson(_timetableJson.first),
        ]);

        final adminItem = TimetableItemModel.fromEntity(
          const TimetableItem(
            id: 'admin_t1',
            courseName: 'Admin Course',
            instructor: 'Admin',
            room: 'X-100',
            dayOfWeek: 3,
            startTime: '14:00',
            endTime: '15:30',
            status: 'Upcoming',
          ),
        );
        await dao.insertOne(adminItem);

        await dao.insertAll([
          TimetableItemModel.fromJson(_timetableJson.first),
        ]);

        final cached = await dao.getAll();
        expect(cached.length, 2);
        expect(cached.any((t) => t.id == 'admin_t1'), isTrue);
      },
    );

    test(
      'AnnouncementLocalDao: admin-edited row survives subsequent insertAll',
      () async {
        final dao = AnnouncementLocalDao(localDb);

        // Seed a server row.
        await dao.insertAll([
          AnnouncementModel.fromJson(_announcementJson.first),
        ]);

        // Admin edits the title. updateOne should pin it as local.
        final edited = AnnouncementModel.fromEntity(
          Announcement(
            id: '1',
            title: 'Edited Title',
            body: 'Stay safe',
            category: 'Urgent',
            date: DateTime(2026, 4, 1),
          ),
        );
        await dao.updateOne(edited);

        // Re-sync with the original server payload.
        await dao.insertAll([
          AnnouncementModel.fromJson(_announcementJson.first),
        ]);

        final cached = await dao.getAll();
        expect(cached.length, 1);
        expect(cached.first.title, 'Edited Title');
      },
    );
  });
}
