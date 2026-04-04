# SmartCampus Companion

A mobile app that demonstrates essential concepts of mobile operating systems using Flutter & Dart.

## Features (Planned)

- **Authentication & biometric unlock** — Secure login with fingerprint/face ID
- **Announcements feed** — Campus-wide announcements with category filters
- **Events calendar** — Browse and track upcoming campus events
- **Timetable management** — View weekly schedule, export as JSON
- **Offline-first caching** — Local SQLite/Hive storage for offline access
- **Campus map** — Interactive map with GPS-based location
- **Push notifications** — Class reminders, event alerts, announcement updates
- **Background refresh** — Sync data in the background
- **Camera/gallery integration** — Profile photos, document capture
- **Sensor features** — Shake-to-refresh using accelerometer
- **Light/dark/system theme** — Full Material 3 theming with accessibility support
- **Schedule export** — Export timetable data as JSON

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter (stable) with Dart null safety |
| **Architecture** | Clean Architecture-lite (Data / Domain / Presentation) |
| **State Management** | ValueNotifier (Sprint 1), flutter_bloc (Sprint 2+) |
| **Routing** | onGenerateRoute with named routes |
| **Networking** | Dio (Sprint 2) |
| **Local Storage** | SQLite / Hive + SharedPreferences (Sprint 3) |
| **Auth** | JWT + Flutter Secure Storage (Sprint 6) |

## Getting Started

```bash
# Clone the repository
git clone https://github.com/Haroun-Azoulay/smart-campus-companion.git
cd smart-campus-companion

# Install dependencies
flutter pub get

# Run the app
flutter run

# Run analysis
flutter analyze

# Run tests
flutter test
```

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        # Semantic color palette
│   │   ├── app_routes.dart        # Route name constants
│   │   └── app_strings.dart       # UI string constants
│   ├── theme/
│   │   ├── app_theme.dart         # Light & dark ThemeData
│   │   └── text_styles.dart       # Typography definitions
│   ├── utils/
│   │   └── helpers.dart           # Date formatting, string utilities
│   ├── widgets/
│   │   └── common_widgets.dart    # Loading, Error, EmptyState, OfflineBanner
│   └── router.dart                # Centralized route generator
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   └── local_database.dart    # SQLite/Hive stub (Sprint 3)
│   │   └── remote/
│   │       └── api_client.dart        # Dio REST client stub (Sprint 2)
│   ├── models/
│   │   ├── announcement_model.dart    # Announcement DTO
│   │   ├── event_model.dart           # Event DTO
│   │   └── timetable_item_model.dart  # TimetableItem DTO
│   └── repositories/
│       └── announcement_repository_impl.dart  # Concrete implementation
├── domain/
│   ├── entities/
│   │   ├── announcement.dart      # Pure business object
│   │   ├── event.dart             # Pure business object
│   │   └── timetable_item.dart    # Pure business object
│   ├── repositories/
│   │   ├── announcement_repository.dart   # Abstract interface
│   │   ├── event_repository.dart          # Abstract interface
│   │   └── timetable_repository.dart      # Abstract interface
│   └── usecases/                  # Business logic (future sprints)
├── presentation/
│   ├── blocs/
│   │   └── theme/
│   │       └── theme_cubit.dart   # ThemeMode state (light/dark/system)
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart           # Dashboard with stats & announcements
│   │   ├── announcements/
│   │   │   └── announcements_screen.dart  # Announcements list
│   │   ├── events/
│   │   │   └── events_screen.dart         # Events list
│   │   ├── settings/
│   │   │   └── settings_screen.dart       # Settings with theme selector
│   │   └── not_found_screen.dart          # 404 page
│   └── widgets/
│       └── main_shell.dart        # BottomNav + IndexedStack shell
├── app.dart                       # MaterialApp configuration
└── main.dart                      # Entry point
```

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for detailed architecture documentation.

## Screenshots

> Screenshots will be added as features are implemented across sprints.

| Screen | Light | Dark |
|--------|-------|------|
| Home Dashboard | _coming soon_ | _coming soon_ |
| Announcements | _coming soon_ | _coming soon_ |
| Events | _coming soon_ | _coming soon_ |
| Settings | _coming soon_ | _coming soon_ |

## Branching Strategy

```
main          ← stable, always deployable
└── develop   ← integration branch, all features merge here
    ├── feature/navigation    ← bottom nav + routing
    ├── feature/theming       ← theme system + accessibility
    └── feature/...           ← future features
```

## Sprint Progress

- [x] Sprint 1: Project setup, navigation, theming, folder structure
- [ ] Sprint 2: Data models, networking, REST API
- [ ] Sprint 3: Local persistence, offline mode, file I/O
- [ ] Sprint 4: Permissions, camera, location, sensors
- [ ] Sprint 5: Notifications, background tasks, lifecycle
- [ ] Sprint 6: Auth, biometrics, security, performance
- [ ] Sprint 7: Testing, bug fixes, technical report
- [ ] Sprint 8: Final delivery, demo video, presentation
