import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/core/errors/app_exceptions.dart';
import 'package:smart_campus/domain/entities/event.dart';
import 'package:smart_campus/domain/repositories/event_repository.dart';
import 'package:smart_campus/presentation/blocs/event/event_bloc.dart';
import 'package:smart_campus/presentation/blocs/event/event_event.dart';
import 'package:smart_campus/presentation/blocs/event/event_state.dart';

class FakeEventRepository implements EventRepository {
  List<Event>? result;
  AppException? error;

  @override
  Future<List<Event>> getEvents() async {
    if (error != null) throw error!;
    return result!;
  }

  @override
  Future<Event?> getEventById(String id) async {
    if (error != null) throw error!;
    return result?.where((e) => e.id == id).firstOrNull;
  }

  @override
  Future<Event> createEvent(Event e) async => e;

  @override
  Future<Event> updateEvent(Event e) async => e;

  @override
  Future<void> deleteEvent(String id) async {}
}

final _sampleEvents = [
  Event(
    id: '1',
    title: 'Hackathon',
    description: 'Annual coding competition',
    location: 'Building A',
    dateTime: DateTime(2026, 5, 1),
    category: 'Tech',
  ),
  Event(
    id: '2',
    title: 'Career Fair',
    description: 'Meet top companies',
    location: 'Main Hall',
    dateTime: DateTime(2026, 5, 10),
    category: 'Career',
  ),
];

void main() {
  late FakeEventRepository fakeRepo;
  late EventBloc bloc;

  setUp(() {
    fakeRepo = FakeEventRepository();
    bloc = EventBloc(repository: fakeRepo);
  });

  tearDown(() => bloc.close());

  group('EventBloc — offline scenarios', () {
    test('emits Loaded with cached events', () async {
      fakeRepo.result = _sampleEvents;

      bloc.add(const FetchEvents());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<EventLoading>(),
          isA<EventLoaded>().having((s) => s.events.length, 'count', 2),
        ]),
      );
    });

    test('emits Error when offline with empty cache', () async {
      fakeRepo.error = const CacheException();

      bloc.add(const FetchEvents());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<EventLoading>(),
          isA<EventError>().having(
            (s) => s.message,
            'message',
            contains('cached data'),
          ),
        ]),
      );
    });

    test('refresh emits Error when offline with empty cache', () async {
      fakeRepo.error = const CacheException();

      bloc.add(const RefreshEvents());
      await expectLater(bloc.stream, emits(isA<EventError>()));
    });

    test('retry after error loads cached data successfully', () async {
      fakeRepo.error = const CacheException();
      bloc.add(const FetchEvents());
      await expectLater(bloc.stream, emitsThrough(isA<EventError>()));

      fakeRepo.error = null;
      fakeRepo.result = _sampleEvents;
      bloc.add(const FetchEvents());
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<EventLoaded>().having((s) => s.events.length, 'count', 2),
        ),
      );
    });

    test('search works on cached data', () async {
      fakeRepo.result = _sampleEvents;

      bloc.add(const SearchEvents('hackathon'));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<EventLoaded>().having(
            (s) => s.events.length,
            'filtered count',
            1,
          ),
        ),
      );
    });

    test('toggle reminder works on cached data without network', () async {
      fakeRepo.result = _sampleEvents;

      bloc.add(const FetchEvents());
      await expectLater(bloc.stream, emitsThrough(isA<EventLoaded>()));

      bloc.add(const ToggleReminder('1'));
      await expectLater(
        bloc.stream,
        emits(
          isA<EventLoaded>().having(
            (s) => s.events.firstWhere((e) => e.id == '1').isReminded,
            'isReminded',
            true,
          ),
        ),
      );
    });
  });
}
