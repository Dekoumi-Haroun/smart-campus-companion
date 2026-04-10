import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smart_campus/core/errors/app_exceptions.dart';
import 'package:smart_campus/domain/entities/announcement.dart';
import 'package:smart_campus/domain/repositories/announcement_repository.dart';
import 'package:smart_campus/presentation/blocs/announcement/announcement_bloc.dart';
import 'package:smart_campus/presentation/blocs/announcement/announcement_event.dart';
import 'package:smart_campus/presentation/blocs/announcement/announcement_state.dart';

class MockAnnouncementRepository extends Mock
    implements AnnouncementRepository {}

void main() {
  late MockAnnouncementRepository mockRepo;

  final testAnnouncements = [
    Announcement(
      id: '1',
      title: 'Library Hours',
      body: 'Extended hours during exams',
      category: 'Academic',
      date: DateTime(2026, 4, 7),
      summary: 'Library open late',
      source: 'Admin',
      readTime: 2,
      isBookmarked: false,
    ),
    Announcement(
      id: '2',
      title: 'Sports Day',
      body: 'Annual sports event',
      category: 'Sports',
      date: DateTime(2026, 4, 10),
      summary: 'Come join',
      source: 'Athletics',
      readTime: 1,
      isBookmarked: false,
    ),
  ];

  setUp(() {
    mockRepo = MockAnnouncementRepository();
  });

  group('AnnouncementBloc', () {
    blocTest<AnnouncementBloc, AnnouncementState>(
      'initial state is AnnouncementInitial',
      build: () {
        when(
          () => mockRepo.getAnnouncements(),
        ).thenAnswer((_) async => testAnnouncements);
        return AnnouncementBloc(repository: mockRepo);
      },
      verify: (bloc) => expect(bloc.state, const AnnouncementInitial()),
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'FetchAnnouncements emits [Loading, Loaded] on success',
      build: () {
        when(
          () => mockRepo.getAnnouncements(),
        ).thenAnswer((_) async => testAnnouncements);
        return AnnouncementBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const FetchAnnouncements()),
      expect: () => [
        const AnnouncementLoading(),
        AnnouncementLoaded(testAnnouncements),
      ],
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'FetchAnnouncements emits [Loading, Error] on CacheException',
      build: () {
        when(
          () => mockRepo.getAnnouncements(),
        ).thenThrow(const CacheException());
        return AnnouncementBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const FetchAnnouncements()),
      expect: () => [const AnnouncementLoading(), isA<AnnouncementError>()],
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'RefreshAnnouncements emits [Loaded] without Loading state',
      build: () {
        when(
          () => mockRepo.getAnnouncements(),
        ).thenAnswer((_) async => testAnnouncements);
        return AnnouncementBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const RefreshAnnouncements()),
      expect: () => [AnnouncementLoaded(testAnnouncements)],
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'FilterByCategory filters announcements by category',
      build: () {
        when(
          () => mockRepo.getAnnouncements(),
        ).thenAnswer((_) async => testAnnouncements);
        return AnnouncementBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const FilterByCategory('Academic')),
      expect: () => [
        const AnnouncementLoading(),
        AnnouncementLoaded([testAnnouncements.first]),
      ],
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'FilterByCategory with "All" returns all announcements',
      build: () {
        when(
          () => mockRepo.getAnnouncements(),
        ).thenAnswer((_) async => testAnnouncements);
        return AnnouncementBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const FilterByCategory('All')),
      expect: () => [
        const AnnouncementLoading(),
        AnnouncementLoaded(testAnnouncements),
      ],
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'SearchAnnouncements filters by query text',
      build: () {
        when(
          () => mockRepo.getAnnouncements(),
        ).thenAnswer((_) async => testAnnouncements);
        return AnnouncementBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const SearchAnnouncements('library')),
      expect: () => [
        const AnnouncementLoading(),
        AnnouncementLoaded([testAnnouncements.first]),
      ],
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'SearchAnnouncements with empty query returns all',
      build: () {
        when(
          () => mockRepo.getAnnouncements(),
        ).thenAnswer((_) async => testAnnouncements);
        return AnnouncementBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const SearchAnnouncements('')),
      expect: () => [
        const AnnouncementLoading(),
        AnnouncementLoaded(testAnnouncements),
      ],
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'FetchAnnouncements emits [Loading, Error] on NetworkException',
      build: () {
        when(
          () => mockRepo.getAnnouncements(),
        ).thenThrow(const NetworkException());
        return AnnouncementBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const FetchAnnouncements()),
      expect: () => [const AnnouncementLoading(), isA<AnnouncementError>()],
    );
  });
}
