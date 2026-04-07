import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/core/errors/app_exceptions.dart';
import 'package:smart_campus/domain/entities/timetable_item.dart';
import 'package:smart_campus/domain/repositories/timetable_repository.dart';
import 'package:smart_campus/presentation/blocs/timetable/timetable_bloc.dart';
import 'package:smart_campus/presentation/blocs/timetable/timetable_event.dart';
import 'package:smart_campus/presentation/blocs/timetable/timetable_state.dart';

class FakeTimetableRepository implements TimetableRepository {
  List<TimetableItem>? result;
  List<TimetableItem>? dayResult;
  String? exportFilePath;
  AppException? fetchError;
  AppException? exportError;

  @override
  Future<List<TimetableItem>> getTimetable() async {
    if (fetchError != null) throw fetchError!;
    return result!;
  }

  @override
  Future<List<TimetableItem>> getTimetableByDay(int dayOfWeek) async {
    if (fetchError != null) throw fetchError!;
    return dayResult ?? result!.where((i) => i.dayOfWeek == dayOfWeek).toList();
  }

  @override
  Future<String> exportToJson() async {
    if (exportError != null) throw exportError!;
    return exportFilePath!;
  }
}

final _sampleItems = [
  const TimetableItem(
    id: '1',
    courseName: 'Mobile Dev',
    instructor: 'Dr. Smith',
    room: 'B201',
    dayOfWeek: 1,
    startTime: '09:00',
    endTime: '10:30',
    status: 'Upcoming',
  ),
  const TimetableItem(
    id: '2',
    courseName: 'Algorithms',
    instructor: 'Prof. Jones',
    room: 'A102',
    dayOfWeek: 2,
    startTime: '11:00',
    endTime: '12:30',
    status: 'Upcoming',
  ),
];

void main() {
  late FakeTimetableRepository fakeRepo;
  late TimetableBloc bloc;

  setUp(() {
    fakeRepo = FakeTimetableRepository();
    bloc = TimetableBloc(repository: fakeRepo);
  });

  tearDown(() => bloc.close());

  group('TimetableBloc — offline scenarios', () {
    test('emits Loaded with cached timetable', () async {
      fakeRepo.result = _sampleItems;

      bloc.add(const FetchTimetable());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<TimetableLoading>(),
          isA<TimetableLoaded>().having((s) => s.items.length, 'count', 2),
        ]),
      );
    });

    test('emits Error when offline with empty cache', () async {
      fakeRepo.fetchError = const CacheException();

      bloc.add(const FetchTimetable());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<TimetableLoading>(),
          isA<TimetableError>().having(
            (s) => s.message,
            'message',
            contains('cached data'),
          ),
        ]),
      );
    });

    test('fetch by day works with cached data', () async {
      fakeRepo.result = _sampleItems;

      bloc.add(const FetchTimetableByDay(1));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<TimetableLoaded>().having(
            (s) => s.items.length,
            'Monday count',
            1,
          ),
        ),
      );
    });

    test('fetch by day emits Error when offline with empty cache', () async {
      fakeRepo.fetchError = const CacheException();

      bloc.add(const FetchTimetableByDay(1));
      await expectLater(bloc.stream, emitsThrough(isA<TimetableError>()));
    });

    test('export from cached data emits TimetableExported', () async {
      fakeRepo.exportFilePath = '/docs/timetable_export_123.json';

      bloc.add(const ExportTimetable());
      await expectLater(
        bloc.stream,
        emits(
          isA<TimetableExported>().having(
            (s) => s.filePath,
            'filePath',
            '/docs/timetable_export_123.json',
          ),
        ),
      );
    });

    test('export emits Error when offline with empty cache', () async {
      fakeRepo.exportError = const CacheException();

      bloc.add(const ExportTimetable());
      await expectLater(
        bloc.stream,
        emits(
          isA<TimetableError>().having(
            (s) => s.message,
            'message',
            contains('cached data'),
          ),
        ),
      );
    });

    test('retry after fetch error loads data successfully', () async {
      fakeRepo.fetchError = const CacheException();
      bloc.add(const FetchTimetable());
      await expectLater(bloc.stream, emitsThrough(isA<TimetableError>()));

      fakeRepo.fetchError = null;
      fakeRepo.result = _sampleItems;
      bloc.add(const FetchTimetable());
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<TimetableLoaded>().having((s) => s.items.length, 'count', 2),
        ),
      );
    });
  });
}
