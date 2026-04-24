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

  group('EventBloc — AttachPhoto', () {
    test('updates the correct event photoPath', () async {
      fakeRepo.result = _sampleEvents;

      bloc.add(const FetchEvents());
      await expectLater(bloc.stream, emitsThrough(isA<EventLoaded>()));

      bloc.add(const AttachPhoto('1', '/path/to/photo.jpg'));
      await expectLater(
        bloc.stream,
        emits(
          isA<EventLoaded>().having(
            (s) => s.events.firstWhere((e) => e.id == '1').photoPath,
            'photoPath',
            '/path/to/photo.jpg',
          ),
        ),
      );
    });

    test('does not modify other events', () async {
      fakeRepo.result = _sampleEvents;

      bloc.add(const FetchEvents());
      await expectLater(bloc.stream, emitsThrough(isA<EventLoaded>()));

      bloc.add(const AttachPhoto('1', '/path/to/photo.jpg'));
      await expectLater(
        bloc.stream,
        emits(
          isA<EventLoaded>().having(
            (s) => s.events.firstWhere((e) => e.id == '2').photoPath,
            'other event photoPath',
            isNull,
          ),
        ),
      );
    });

    test('overwrites existing photoPath', () async {
      fakeRepo.result = _sampleEvents;

      bloc.add(const FetchEvents());
      await expectLater(bloc.stream, emitsThrough(isA<EventLoaded>()));

      bloc.add(const AttachPhoto('1', '/old.jpg'));
      await expectLater(bloc.stream, emitsThrough(isA<EventLoaded>()));

      bloc.add(const AttachPhoto('1', '/new.jpg'));
      await expectLater(
        bloc.stream,
        emits(
          isA<EventLoaded>().having(
            (s) => s.events.firstWhere((e) => e.id == '1').photoPath,
            'updated photoPath',
            '/new.jpg',
          ),
        ),
      );
    });

    test('does nothing when state is not EventLoaded', () async {
      // Bloc is in initial state — AttachPhoto should be ignored.
      bloc.add(const AttachPhoto('1', '/path.jpg'));
      // Give time for event processing.
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state, isA<EventInitial>());
    });
  });
}
