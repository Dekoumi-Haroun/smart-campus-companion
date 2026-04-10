import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smart_campus/core/errors/app_exceptions.dart';
import 'package:smart_campus/domain/entities/timetable_item.dart';
import 'package:smart_campus/domain/repositories/timetable_repository.dart';
import 'package:smart_campus/presentation/blocs/timetable/timetable_bloc.dart';
import 'package:smart_campus/presentation/blocs/timetable/timetable_event.dart';
import 'package:smart_campus/presentation/blocs/timetable/timetable_state.dart';

class MockTimetableRepository extends Mock implements TimetableRepository {}

void main() {
  late MockTimetableRepository mockRepo;

  final testItems = [
    const TimetableItem(
      id: 't1',
      courseName: 'Mobile Dev',
      instructor: 'Dr. Smith',
      room: 'B201',
      dayOfWeek: 1,
      startTime: '09:00',
      endTime: '10:30',
      status: 'Upcoming',
    ),
    const TimetableItem(
      id: 't2',
      courseName: 'Algorithms',
      instructor: 'Prof. Lee',
      room: 'C302',
      dayOfWeek: 2,
      startTime: '14:00',
      endTime: '15:30',
      status: 'Upcoming',
    ),
  ];

  setUp(() {
    mockRepo = MockTimetableRepository();
  });

  group('TimetableBloc', () {
    blocTest<TimetableBloc, TimetableState>(
      'initial state is TimetableInitial',
      build: () => TimetableBloc(repository: mockRepo),
      verify: (bloc) => expect(bloc.state, const TimetableInitial()),
    );

    blocTest<TimetableBloc, TimetableState>(
      'FetchTimetable emits [Loading, Loaded] on success',
      build: () {
        when(() => mockRepo.getTimetable()).thenAnswer((_) async => testItems);
        return TimetableBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const FetchTimetable()),
      expect: () => [const TimetableLoading(), TimetableLoaded(testItems)],
    );

    blocTest<TimetableBloc, TimetableState>(
      'FetchTimetable emits [Loading, Error] on CacheException',
      build: () {
        when(() => mockRepo.getTimetable()).thenThrow(const CacheException());
        return TimetableBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const FetchTimetable()),
      expect: () => [const TimetableLoading(), isA<TimetableError>()],
    );

    blocTest<TimetableBloc, TimetableState>(
      'FetchTimetableByDay emits filtered items for matching day',
      build: () {
        when(
          () => mockRepo.getTimetableByDay(1),
        ).thenAnswer((_) async => [testItems.first]);
        return TimetableBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const FetchTimetableByDay(1)),
      expect: () => [
        const TimetableLoading(),
        TimetableLoaded([testItems.first]),
      ],
    );

    blocTest<TimetableBloc, TimetableState>(
      'ExportTimetable emits [Exported] on success',
      build: () {
        when(
          () => mockRepo.exportToJson(),
        ).thenAnswer((_) async => '/path/timetable.json');
        return TimetableBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const ExportTimetable()),
      expect: () => [const TimetableExported('/path/timetable.json')],
    );

    blocTest<TimetableBloc, TimetableState>(
      'ExportTimetable emits [Error] on failure',
      build: () {
        when(() => mockRepo.exportToJson()).thenThrow(const CacheException());
        return TimetableBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const ExportTimetable()),
      expect: () => [isA<TimetableError>()],
    );
  });
}
