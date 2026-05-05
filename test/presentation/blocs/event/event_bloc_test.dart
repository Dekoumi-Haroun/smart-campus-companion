import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smart_campus/core/errors/app_exceptions.dart';
import 'package:smart_campus/domain/entities/event.dart';
import 'package:smart_campus/domain/repositories/event_repository.dart';
import 'package:smart_campus/presentation/blocs/event/event_bloc.dart';
import 'package:smart_campus/presentation/blocs/event/event_event.dart';
import 'package:smart_campus/presentation/blocs/event/event_state.dart';

class MockEventRepository extends Mock implements EventRepository {}

void main() {
  late MockEventRepository mockRepo;

  final testEvents = [
    Event(
      id: 'e1',
      title: 'Open Day',
      description: 'Campus visit',
      location: 'Main Gate',
      dateTime: DateTime(2026, 5, 1, 10),
      category: 'General',
      attendeeCount: 100,
    ),
    Event(
      id: 'e2',
      title: 'Hackathon',
      description: 'Code all night',
      location: 'Lab B',
      dateTime: DateTime(2026, 5, 5, 18),
      category: 'Tech',
      attendeeCount: 50,
    ),
  ];

  setUp(() {
    mockRepo = MockEventRepository();
  });

  group('EventBloc', () {
    blocTest<EventBloc, EventState>(
      'initial state is EventInitial',
      build: () => EventBloc(repository: mockRepo),
      verify: (bloc) => expect(bloc.state, const EventInitial()),
    );

    blocTest<EventBloc, EventState>(
      'FetchEvents emits [Loading, Loaded] on success',
      build: () {
        when(() => mockRepo.getEvents()).thenAnswer((_) async => testEvents);
        return EventBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const FetchEvents()),
      expect: () => [const EventLoading(), EventLoaded(testEvents)],
    );

    blocTest<EventBloc, EventState>(
      'FetchEvents emits [Loading, Error] on CacheException',
      build: () {
        when(() => mockRepo.getEvents()).thenThrow(const CacheException());
        return EventBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const FetchEvents()),
      expect: () => [const EventLoading(), isA<EventError>()],
    );

    blocTest<EventBloc, EventState>(
      'SearchEvents filters by query',
      build: () {
        when(() => mockRepo.getEvents()).thenAnswer((_) async => testEvents);
        return EventBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const SearchEvents('hackathon')),
      expect: () => [
        const EventLoading(),
        EventLoaded([testEvents[1]]),
      ],
    );

    blocTest<EventBloc, EventState>(
      'SearchEvents with empty query returns all events',
      build: () {
        when(() => mockRepo.getEvents()).thenAnswer((_) async => testEvents);
        return EventBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const SearchEvents('')),
      expect: () => [const EventLoading(), EventLoaded(testEvents)],
    );

    blocTest<EventBloc, EventState>(
      'ToggleReminder toggles isReminded flag on matching event',
      build: () {
        when(() => mockRepo.getEvents()).thenAnswer((_) async => testEvents);
        return EventBloc(repository: mockRepo);
      },
      seed: () => EventLoaded(testEvents),
      act: (bloc) => bloc.add(const ToggleReminder('e1')),
      expect: () => [
        isA<EventLoaded>().having(
          (s) => s.events.first.isReminded,
          'first event isReminded',
          true,
        ),
      ],
    );

    blocTest<EventBloc, EventState>(
      'ToggleReminder does nothing when state is not EventLoaded',
      build: () => EventBloc(repository: mockRepo),
      act: (bloc) => bloc.add(const ToggleReminder('e1')),
      expect: () => <EventState>[],
    );

    blocTest<EventBloc, EventState>(
      'AttachPhoto sets photoPath on matching event',
      build: () {
        when(() => mockRepo.getEvents()).thenAnswer((_) async => testEvents);
        return EventBloc(repository: mockRepo);
      },
      seed: () => EventLoaded(testEvents),
      act: (bloc) => bloc.add(const AttachPhoto('e2', '/path/photo.jpg')),
      expect: () => [
        isA<EventLoaded>().having(
          (s) => s.events[1].photoPath,
          'second event photoPath',
          '/path/photo.jpg',
        ),
      ],
    );

    blocTest<EventBloc, EventState>(
      'RefreshEvents emits [Loaded] without Loading first',
      build: () {
        when(() => mockRepo.getEvents()).thenAnswer((_) async => testEvents);
        return EventBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const RefreshEvents()),
      expect: () => [EventLoaded(testEvents)],
    );
  });
}
