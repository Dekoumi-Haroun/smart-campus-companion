import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_campus/core/errors/app_exceptions.dart';
import 'package:smart_campus/data/datasources/local/announcement_local_dao.dart';
import 'package:smart_campus/data/datasources/local/event_local_dao.dart';
import 'package:smart_campus/data/datasources/local/local_database.dart';
import 'package:smart_campus/data/datasources/local/timetable_local_dao.dart';
import 'package:smart_campus/data/datasources/remote/api_client.dart';
import 'package:smart_campus/data/repositories/announcement_repository_impl.dart';
import 'package:smart_campus/data/repositories/event_repository_impl.dart';
import 'package:smart_campus/data/repositories/timetable_repository_impl.dart';

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
}
