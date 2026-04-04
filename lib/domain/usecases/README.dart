/// Use cases (optional in Clean Architecture-lite).
///
/// Use cases encapsulate a single piece of business logic. For this project,
/// the repositories handle most logic directly, but use cases can be added
/// if a business operation involves coordination between multiple repositories.
///
/// Example (future):
/// ```dart
/// class GetDashboardDataUseCase {
///   final AnnouncementRepository _announcements;
///   final EventRepository _events;
///   final TimetableRepository _timetable;
///
///   Future<DashboardData> execute() async {
///     final results = await Future.wait([
///       _announcements.getAnnouncements(),
///       _events.getEvents(),
///       _timetable.getTimetable(),
///     ]);
///     return DashboardData(...);
///   }
/// }
/// ```
