import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/core/errors/app_exceptions.dart';
import 'package:smart_campus/domain/entities/announcement.dart';
import 'package:smart_campus/domain/repositories/announcement_repository.dart';
import 'package:smart_campus/presentation/blocs/announcement/announcement_bloc.dart';
import 'package:smart_campus/presentation/blocs/announcement/announcement_event.dart';
import 'package:smart_campus/presentation/blocs/announcement/announcement_state.dart';

class FakeAnnouncementRepository implements AnnouncementRepository {
  List<Announcement>? result;
  AppException? error;

  @override
  Future<List<Announcement>> getAnnouncements() async {
    if (error != null) throw error!;
    return result!;
  }

  @override
  Future<Announcement?> getAnnouncementById(String id) async {
    if (error != null) throw error!;
    return result?.where((a) => a.id == id).firstOrNull;
  }
}

final _sampleAnnouncements = [
  Announcement(
    id: '1',
    title: 'Campus closed',
    body: 'Due to weather',
    category: 'General',
    date: DateTime(2026, 4, 1),
  ),
  Announcement(
    id: '2',
    title: 'New library hours',
    body: 'Extended hours this week',
    category: 'Academic',
    date: DateTime(2026, 4, 2),
  ),
];

void main() {
  late FakeAnnouncementRepository fakeRepo;
  late AnnouncementBloc bloc;

  setUp(() {
    fakeRepo = FakeAnnouncementRepository();
    bloc = AnnouncementBloc(repository: fakeRepo);
  });

  tearDown(() => bloc.close());

  group('AnnouncementBloc — offline scenarios', () {
    test(
      'emits Loaded with cached data when repo returns cached list',
      () async {
        // Simulate: network failed but repo returned cached data.
        fakeRepo.result = _sampleAnnouncements;

        bloc.add(const FetchAnnouncements());
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<AnnouncementLoading>(),
            isA<AnnouncementLoaded>().having(
              (s) => s.announcements.length,
              'count',
              2,
            ),
          ]),
        );
      },
    );

    test(
      'emits Error with CacheException when offline and cache is empty',
      () async {
        fakeRepo.error = const CacheException();

        bloc.add(const FetchAnnouncements());
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<AnnouncementLoading>(),
            isA<AnnouncementError>().having(
              (s) => s.message,
              'message',
              contains('cached data'),
            ),
          ]),
        );
      },
    );

    test('refresh emits Error when offline and cache is empty', () async {
      fakeRepo.error = const CacheException();

      bloc.add(const RefreshAnnouncements());
      await expectLater(bloc.stream, emits(isA<AnnouncementError>()));
    });

    test('retry after error loads cached data successfully', () async {
      // First attempt: no cache.
      fakeRepo.error = const CacheException();
      bloc.add(const FetchAnnouncements());
      await expectLater(bloc.stream, emitsThrough(isA<AnnouncementError>()));

      // Second attempt: cache now populated (simulated).
      fakeRepo.error = null;
      fakeRepo.result = _sampleAnnouncements;
      bloc.add(const FetchAnnouncements());
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<AnnouncementLoaded>().having(
            (s) => s.announcements.length,
            'count',
            2,
          ),
        ),
      );
    });

    test('filter works on cached data', () async {
      fakeRepo.result = _sampleAnnouncements;

      bloc.add(const FilterByCategory('Academic'));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<AnnouncementLoaded>().having(
            (s) => s.announcements.length,
            'filtered count',
            1,
          ),
        ),
      );
    });

    test('search works on cached data', () async {
      fakeRepo.result = _sampleAnnouncements;

      bloc.add(const SearchAnnouncements('library'));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<AnnouncementLoaded>().having(
            (s) => s.announcements.first.title,
            'title',
            'New library hours',
          ),
        ),
      );
    });
  });
}
