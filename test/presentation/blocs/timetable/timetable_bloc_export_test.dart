import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/core/errors/app_exceptions.dart';
import 'package:smart_campus/domain/entities/timetable_item.dart';
import 'package:smart_campus/domain/repositories/timetable_repository.dart';
import 'package:smart_campus/presentation/blocs/timetable/timetable_bloc.dart';
import 'package:smart_campus/presentation/blocs/timetable/timetable_event.dart';
import 'package:smart_campus/presentation/blocs/timetable/timetable_state.dart';

/// Fake repository that returns a controlled file path or throws.
class FakeTimetableRepository implements TimetableRepository {
  String? exportResult;
  AppException? exportError;

  @override
  Future<String> exportToJson() async {
    if (exportError != null) throw exportError!;
    return exportResult!;
  }

  @override
  Future<List<TimetableItem>> getTimetable() async => [];

  @override
  Future<List<TimetableItem>> getTimetableByDay(int dayOfWeek) async => [];
}

void main() {
  late FakeTimetableRepository fakeRepo;
  late TimetableBloc bloc;

  setUp(() {
    fakeRepo = FakeTimetableRepository();
    bloc = TimetableBloc(repository: fakeRepo);
  });

  tearDown(() => bloc.close());

  group('TimetableBloc — ExportTimetable', () {
    test('emits TimetableExported with file path on success', () async {
      fakeRepo.exportResult = '/documents/timetable_export_123.json';

      bloc.add(const ExportTimetable());
      await expectLater(
        bloc.stream,
        emits(
          isA<TimetableExported>().having(
            (s) => s.filePath,
            'filePath',
            '/documents/timetable_export_123.json',
          ),
        ),
      );
    });

    test('emits TimetableError when export fails', () async {
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
  });
}
