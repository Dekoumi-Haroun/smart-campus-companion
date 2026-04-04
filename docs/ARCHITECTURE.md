# SmartCampus Companion — Architecture Guide

## Clean Architecture-Lite Overview

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │  Screens  │  │  BLoCs/  │  │ Widgets  │              │
│  │  (Pages)  │←─│  Cubits  │  │(Reusable)│              │
│  └──────────┘  └────┬─────┘  └──────────┘              │
│                     │ depends on                         │
├─────────────────────┼───────────────────────────────────┤
│                  DOMAIN LAYER                            │
│  ┌──────────┐  ┌────┴─────┐  ┌──────────┐              │
│  │ Entities │  │Repository│  │ UseCases │              │
│  │  (pure)  │  │Interfaces│  │(optional)│              │
│  └──────────┘  └────┬─────┘  └──────────┘              │
│                     │ implemented by                     │
├─────────────────────┼───────────────────────────────────┤
│                    DATA LAYER                            │
│  ┌──────────┐  ┌────┴─────┐  ┌──────────┐              │
│  │  Models   │  │Repository│  │  Data    │              │
│  │  (DTOs)  │  │  Impls   │  │ Sources  │              │
│  └──────────┘  └──────────┘  └────┬─────┘              │
│                              ┌────┴────┐                │
│                              │         │                │
│                         ┌────┴──┐ ┌───┴────┐           │
│                         │Remote │ │ Local  │           │
│                         │ (API) │ │(SQLite)│           │
│                         └───────┘ └────────┘           │
└─────────────────────────────────────────────────────────┘
```

## Dependency Rule

**Presentation → Domain ← Data**

- Presentation depends on Domain (uses entities and repository interfaces)
- Data depends on Domain (implements repository interfaces)
- Domain depends on NOTHING (pure Dart, no Flutter imports)

## Folder Mapping

| Folder | Layer | Purpose |
|--------|-------|---------|
| `lib/core/` | Shared | Constants, theme, utils, reusable widgets |
| `lib/domain/entities/` | Domain | Pure business objects (Announcement, Event, TimetableItem) |
| `lib/domain/repositories/` | Domain | Abstract interfaces (contracts) |
| `lib/domain/usecases/` | Domain | Business logic coordination (optional) |
| `lib/data/models/` | Data | DTOs with JSON serialization (fromJson/toJson) |
| `lib/data/datasources/remote/` | Data | API client (dio) |
| `lib/data/datasources/local/` | Data | SQLite DB, SharedPreferences, SecureStorage |
| `lib/data/repositories/` | Data | Concrete implementations of domain interfaces |
| `lib/presentation/screens/` | Presentation | Screen widgets (one folder per screen) |
| `lib/presentation/blocs/` | Presentation | State management (BLoC/Cubit) |
| `lib/presentation/widgets/` | Presentation | Shared UI components |

## Navigation Flow

```
main.dart → App (MaterialApp)
               ├── onGenerateRoute → AppRouter
               │     ├── '/'          → MainShell (BottomNav + IndexedStack)
               │     │                    ├── Tab 0: HomeScreen
               │     │                    ├── Tab 1: AnnouncementsScreen
               │     │                    ├── Tab 2: EventsScreen
               │     │                    └── Tab 3: SettingsScreen
               │     ├── '/login'     → LoginScreen (Sprint 6)
               │     ├── '/map'       → CampusMapScreen (Sprint 4)
               │     └── default      → NotFoundScreen (404)
               │
               └── Theme: ThemeCubit (ValueNotifier<ThemeMode>)
```

## State Management Strategy

| Sprint | Approach | Why |
|--------|----------|-----|
| Sprint 1 | ValueNotifier (ThemeCubit) | No external deps needed yet |
| Sprint 2+ | flutter_bloc (BLoC/Cubit) | Handles complex async states (Loading/Loaded/Error) |
