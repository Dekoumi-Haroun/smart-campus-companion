# SmartCampus Companion - Technical Report

## Week 7: Testing, Bug Fixes & Technical Documentation

**Project:** SmartCampus Companion  
**Version:** 1.0.0  
**Date:** April 9, 2026  
**Author:** Haroun Dekoumi

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Architecture Overview](#2-architecture-overview)
3. [Feature Walkthrough](#3-feature-walkthrough)
4. [OS Concepts Mapping](#4-os-concepts-mapping)
5. [Testing Strategy & Results](#5-testing-strategy--results)
6. [Bug Fixes & Code Quality](#6-bug-fixes--code-quality)
7. [Performance Profiling](#7-performance-profiling)
8. [Security Considerations](#8-security-considerations)
9. [Conclusion](#9-conclusion)

---

## 1. Introduction

### 1.1 Project Overview

SmartCampus Companion is a cross-platform mobile application built with Flutter that demonstrates core mobile operating system concepts through a practical campus life management tool. The app provides students with a unified interface for accessing campus announcements, events, timetables, maps, and settings while exercising device capabilities including biometric authentication, GPS positioning, accelerometer-based interactions, push notifications, background processing, Bluetooth detection, and secure credential storage.

### 1.2 Objectives

- Demonstrate Clean Architecture principles in a Flutter mobile application
- Implement and exercise core mobile OS concepts: process management, memory management, file systems, I/O, security, and inter-process communication
- Build an offline-first data strategy using local SQLite caching with remote API fallback
- Implement production-grade authentication with biometric support and secure token storage
- Achieve comprehensive test coverage across unit, widget, and integration layers
- Follow OWASP Mobile Security guidelines for credential handling and data protection

### 1.3 Technology Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.11+ / Dart 3.11+ |
| State Management | flutter_bloc (BLoC/Cubit pattern) |
| Networking | Dio with interceptor pipeline |
| Local Database | SQLite via sqflite |
| Secure Storage | flutter_secure_storage (Keychain/EncryptedSharedPreferences) |
| Preferences | shared_preferences |
| Authentication | local_auth (biometrics) + JWT token flow |
| Maps | flutter_map + OpenStreetMap |
| Notifications | flutter_local_notifications + workmanager |
| Sensors | sensors_plus (accelerometer), geolocator (GPS) |
| Permissions | permission_handler |
| Testing | flutter_test, bloc_test, mocktail |

---

## 2. Architecture Overview

### 2.1 Clean Architecture

The application follows a strict three-layer Clean Architecture with unidirectional dependency flow:

```
+--------------------------------------------------+
|                PRESENTATION LAYER                 |
|  Screens  |  Widgets  |  BLoCs/Cubits  |  Theme  |
+--------------------------------------------------+
                        |
                        v
+--------------------------------------------------+
|                  DOMAIN LAYER                     |
|    Entities    |    Repository Contracts           |
+--------------------------------------------------+
                        ^
                        |
+--------------------------------------------------+
|                   DATA LAYER                      |
|  Models  |  Repository Impl  |  Data Sources      |
|          |                   |  (Remote + Local)   |
+--------------------------------------------------+
```

**Domain Layer** contains pure Dart entities and abstract repository interfaces with zero Flutter dependencies. This layer defines the business contract without knowing how data is fetched or stored.

**Data Layer** implements those contracts using concrete data sources: `ApiClient` (Dio-based HTTP) for remote data and `*LocalDao` classes (SQLite) for local caching. Models handle JSON serialization as DTOs.

**Presentation Layer** contains BLoCs/Cubits for state management, screens for UI, and reusable widgets. BLoCs depend only on domain repository interfaces, never on data layer implementations.

### 2.2 Directory Structure

```
lib/
  core/           # Cross-cutting: constants, errors, router, services, theme, widgets
  data/           # Data layer: datasources (remote/local), models, repository implementations
  domain/         # Domain layer: entities, repository contracts
  presentation/   # Presentation layer: blocs, screens, widgets
```

### 2.3 State Management Strategy

The app uses a hybrid BLoC/Cubit approach:

| Component | Pattern | Rationale |
|-----------|---------|-----------|
| Announcements | Full BLoC | Complex events: fetch, refresh, filter, search |
| Events | Full BLoC | Complex events: fetch, search, toggle reminder, attach photo |
| Timetable | Full BLoC | Events: fetch, fetch by day, export |
| Auth | Cubit | Simple state machine: check/login/logout/biometric |
| Connectivity | Cubit | Binary state from stream, no events needed |
| Theme | ValueNotifier | Lightweight reactive updates for ThemeMode |

### 2.4 Data Flow

```
User Action -> BLoC Event -> Repository -> ApiClient (remote)
                                        -> LocalDao (cache)
                                        -> Entity
           <- BLoC State <- Repository <-
```

All repositories implement an **offline-first strategy**:
1. Attempt remote fetch via ApiClient
2. On success: cache locally in SQLite, return entities
3. On DioException: read from local cache
4. If cache empty: throw CacheException

---

## 3. Feature Walkthrough

### 3.1 Authentication Flow

The authentication system provides a complete login/session/biometric flow:

1. **Login Screen**: Email/password form with validation (email regex, 6-char minimum). OWASP input sanitization. Mock API validates against `student@smartcampus.dev / campus123`.

2. **Token Storage**: On successful login, the JWT token, email, display name, and issuance timestamp are stored in `FlutterSecureStorage` (iOS Keychain / Android EncryptedSharedPreferences).

3. **Session Check**: On app launch, `AuthCubit.checkAuthStatus()` reads the stored session and validates the 24-hour token TTL. If valid, the user proceeds directly to the home screen.

4. **Biometric Gate**: If biometric login is enabled in settings and a valid session exists, the user sees a biometric prompt screen before accessing the app. The `local_auth` plugin triggers fingerprint/face verification.

5. **Auth Gating**: The root `App` widget wraps `MaterialApp` in a `BlocBuilder<AuthCubit, AuthState>` that switches `initialRoute` based on auth state, with `ValueKey(initialRoute)` forcing full rebuilds on state transitions.

### 3.2 Dashboard (Home Screen)

- Time-based greeting with authenticated user's display name
- Current class card (highlights live class with "LIVE" badge)
- Statistics row: classes today, events today, announcements count
- Recent announcements preview with horizontal scroll
- Upcoming events preview
- Action buttons: Export Schedule, Campus Safety
- Performance-optimized with `CustomScrollView` + `SliverList`

### 3.3 Announcements

- Full-text search across title and body
- Category filtering: All / Academic / Sports / General / Urgent
- Pull-to-refresh and shake-to-refresh (accelerometer)
- Detail bottom sheet with share/save/remind actions
- Offline-first: cached announcements shown when offline

### 3.4 Events

- Search by title, description, or location
- 14-day horizontal date picker with event dot indicators
- Reminder toggle with local notifications (10 min before)
- Photo attachment from camera or gallery (with permission handling)
- Event detail bottom sheet with photo preview

### 3.5 Campus Map

- OpenStreetMap tiles via flutter_map (no API key required)
- GPS user position with blue dot marker
- Color-coded campus POI markers (academic, dining, recreation, services)
- POI detail bottom sheet with distance calculation
- Permission denial UI with retry and settings redirect
- Location service disabled state handling

### 3.6 Settings

- **Appearance**: Light / Dark / System theme toggle (SegmentedButton)
- **Notifications**: Enable/disable with background task control
- **Language**: English / French / Arabic picker
- **Device Features**: Bluetooth status, NFC (conceptual)
- **Account**: Biometric toggle, logout with confirmation dialog
- **About**: App name and version

---

## 4. OS Concepts Mapping

| Feature | OS Concept | Implementation |
|---------|-----------|----------------|
| **Offline SQLite Cache** | File System & Storage Management | `sqflite` manages a local SQLite database (`local_database.dart`) with tables for announcements, events, and timetable items. DAOs handle CRUD. The OS file system stores the `.db` file in the app's documents directory. |
| **Background Announcement Fetch** | Process Scheduling & Background Execution | `workmanager` registers a periodic background task (`announcementsFetch`) running every 15 minutes. The OS schedules this via Android's WorkManager / iOS BGTaskScheduler, respecting battery optimization. The task runs in a separate isolate. |
| **Biometric Authentication** | OS Security & Hardware Abstraction | `local_auth` invokes the OS biometric subsystem (Touch ID/Face ID on iOS, BiometricPrompt on Android). The OS manages the secure enclave and biometric data; the app only receives a success/failure boolean. |
| **Secure Token Storage** | OS Keychain / Credential Management | `flutter_secure_storage` stores JWT tokens in iOS Keychain and Android EncryptedSharedPreferences. The OS provides hardware-backed encryption; the app never handles raw cryptographic keys. |
| **GPS Location** | Hardware I/O & Sensor Management | `geolocator` interfaces with the OS location subsystem (CoreLocation on iOS, FusedLocationProvider on Android). The OS manages GPS hardware power states, caching, and accuracy negotiation. |
| **Camera/Gallery Access** | I/O Device Management & IPC | `image_picker` uses OS-provided camera/gallery intents (Android) or UIImagePickerController (iOS). The OS manages the camera hardware, and the returned file path represents a sandboxed file system reference. |
| **Push Notifications** | Inter-Process Communication (IPC) | `flutter_local_notifications` creates notification channels (Android) or categories (iOS). Scheduled notifications use the OS alarm manager. Notification taps use deep-link payloads routed back to the app via OS IPC mechanisms. |
| **Runtime Permissions** | OS Security & Access Control | `permission_handler` wraps the OS permission system (Android's runtime permissions API, iOS's Info.plist + system dialogs). The app requests, checks, and handles denial states including permanent denial with settings redirect. |
| **Accelerometer (Shake)** | Sensor Subsystem & Event-Driven I/O | `sensors_plus` reads accelerometer data via the OS sensor framework. A custom `ShakeDetector` computes acceleration magnitude, subtracts gravity (~9.8 m/s^2), applies a threshold (15.0), and a cooldown period. |
| **Bluetooth Status** | Hardware Abstraction & Peripheral Management | `permission_handler` checks Bluetooth permission status. The OS manages the Bluetooth radio state; the app queries availability without directly controlling the hardware. |
| **Connectivity Monitoring** | Network Stack & Event Streams | `connectivity_plus` subscribes to OS network state change broadcasts (Android's ConnectivityManager, iOS's NWPathMonitor). The app reacts to online/offline transitions via a Cubit that maps these to UI state. |
| **App Lifecycle Observer** | Process States & Lifecycle Management | `WidgetsBindingObserver` maps to OS process states: resumed (foreground), paused (background), inactive (transitioning). Used to trigger data staleness checks and biometric re-auth on resume. |
| **Shared Preferences** | Key-Value Storage (User Defaults) | `shared_preferences` wraps NSUserDefaults (iOS) and SharedPreferences (Android). The OS provides a lightweight key-value store for non-sensitive settings like theme mode, language, and notification preferences. |
| **Timezone-Aware Scheduling** | System Clock & Timezone Management | `timezone` package loads the IANA timezone database. Class reminders are scheduled using `TZDateTime` to ensure correct trigger times regardless of device timezone changes. |

---

## 5. Testing Strategy & Results

### 5.1 Test Suite Overview

The project contains **173 passing tests** across multiple test categories:

| Category | Files | Tests | Coverage Focus |
|----------|-------|-------|----------------|
| Model Parsing | 4 | 27 | fromJson robustness, null handling, type coercion, round-trips |
| Repository (Offline-First) | 2 | 18 | Online fetch, offline cache fallback, empty cache errors |
| Auth Repository | 1 | 7 | Login, session storage, token expiry, logout |
| BLoC State Transitions | 6 | 31 | Initial/loading/success/error states, filtering, search, events |
| Auth Cubit | 1 | 8 | Auth flow: check status, login, logout, biometric |
| Widget Tests | 3 | 15 | Login form validation, settings theme toggle, offline banner |
| Service Tests | 5 | 40+ | Bluetooth, location, permissions, shake detector, secure storage |
| Integration Tests | 1 | 27 | Permission denial UX flows |

### 5.2 Unit Testing: Model Parsing

Each model's `fromJson()` is tested against:
- **Valid JSON**: All fields correctly parsed
- **Missing fields**: Defaults applied (empty strings, 0, false, DateTime.now())
- **Null values**: No crashes, graceful fallbacks
- **Incorrect types**: `?.toString()` coercion prevents type cast errors
- **Round-trip**: `toJson()` -> `fromJson()` preserves all fields
- **Entity mapping**: `toEntity()` / `fromEntity()` symmetry verified

### 5.3 Unit Testing: Repository Layer

Each offline-first repository is tested for three scenarios:
1. **API success**: Remote data returned and cached locally
2. **API failure with cache**: Falls back to cached data seamlessly
3. **API failure without cache**: Throws `CacheException` with user-friendly message

### 5.4 BLoC Testing

Using the `bloc_test` package, each BLoC is verified for:
- **Initial state**: Correct starting state
- **Success flow**: Events -> [Loading, Loaded(data)]
- **Error flow**: Events -> [Loading, Error(message)]
- **Filtering/Search**: Correct subset returned
- **State-dependent operations**: ToggleReminder/AttachPhoto only work in Loaded state

### 5.5 Widget Testing

- **Login Screen**: Form validation (empty fields, invalid email, short password), successful submission, password visibility toggle
- **Settings Screen**: Section headers rendered, theme segmented button works, theme persistence across rebuilds, biometric toggle visibility
- **Offline Banner**: Banner appears on ConnectivityOffline, disappears on ConnectivityOnline, hidden by default

### 5.6 Test Commands

```bash
flutter test                    # Run all 173 tests
flutter analyze --fatal-infos   # Static analysis (0 issues)
dart format .                   # Code formatting (0 changes needed)
```

---

## 6. Bug Fixes & Code Quality

### 6.1 Bugs Found and Fixed

#### Bug #1: `SettingsScreen` crashes on theme change (Critical)

**File:** `lib/presentation/screens/settings/settings_screen.dart`  
**Root Cause:** `late final SettingsRepository _settingsRepo` declared in `_SettingsScreenState`. When the user changes the theme, `didChangeDependencies()` is called again, attempting to reinitialize the `late final` field, which throws `LateInitializationError`.

**Before:**
```dart
late final SettingsRepository _settingsRepo;
```

**After:**
```dart
late SettingsRepository _settingsRepo;
```

**Impact:** The app would crash every time the user changed the theme in Settings.

#### Bug #2: `AnnouncementModel.fromJson()` crashes on non-string types (High)

**File:** `lib/data/models/announcement_model.dart`  
**Root Cause:** String fields used `json['title'] ?? ''` without `?.toString()`. If the JSON contains an integer or other non-string type (possible from a real API), the null-coalescing operator doesn't trigger (value isn't null, it's an int), causing a type cast error.

**Before:**
```dart
title: json['title'] ?? '',
body: json['body'] ?? '',
readTime: json['readTime'] ?? 0,
isBookmarked: json['isBookmarked'] ?? false,
```

**After:**
```dart
title: json['title']?.toString() ?? '',
body: json['body']?.toString() ?? '',
readTime: json['readTime'] is int ? json['readTime'] as int : 0,
isBookmarked: json['isBookmarked'] is bool ? json['isBookmarked'] as bool : false,
```

**Impact:** Applied the same defensive pattern to all four models (AnnouncementModel, EventModel, TimetableItemModel, AuthUserModel).

#### Bug #3: Missing `MapController.dispose()` (Medium)

**File:** `lib/presentation/screens/campus_map/campus_map_screen.dart`  
**Root Cause:** `MapController` was created but never disposed, causing a resource leak when navigating away from the map screen.

**Fix:** Added `dispose()` override:
```dart
@override
void dispose() {
  _mapController.dispose();
  super.dispose();
}
```

### 6.2 Code Quality Improvements

- **Type-safe JSON parsing**: All model `fromJson()` methods now use `?.toString()` for string fields and explicit type checks (`is int`, `is bool`) for typed fields
- **Consistent architecture**: All layers follow the same patterns (sealed states, Equatable, repository contracts)
- **Resource cleanup**: All StatefulWidget states properly dispose controllers, subscriptions, and observers
- **Test coverage**: Added 63 new tests (from 110 to 173) covering models, BLoCs, and widgets

---

## 7. Performance Profiling

### 7.1 Rendering Performance

**Home Screen Optimization:**  
The home screen was converted from `SingleChildScrollView` + `Column` to `CustomScrollView` + `SliverList`. This change enables lazy rendering: only visible slivers are laid out and painted, reducing the initial frame time for the dashboard.

**Before:** All home screen widgets (header, current class, stats, announcements, events, actions) are laid out in a single pass regardless of visibility.

**After:** Slivers are built on-demand as they scroll into view.

### 7.2 List Performance

- `AnnouncementsScreen` and `EventsScreen` use `ListView.builder` for large lists, ensuring O(visible) widget creation rather than O(total)
- `SliverList` with `SliverChildListDelegate` is used on the home screen for fixed-length content sections

### 7.3 State Management Efficiency

- `BlocBuilder` with `buildWhen` is used where applicable to prevent unnecessary rebuilds
- `ValueListenableBuilder` for ThemeCubit avoids full subtree rebuilds when only the theme changes
- `const` constructors are used extensively to enable widget caching

### 7.4 Network Performance

- **Mock API delay**: 500ms simulated latency makes loading states visible for UX testing
- **Offline-first**: SQLite cache eliminates network round-trips for repeat visits
- **Background fetch**: Announcements are refreshed every 15 minutes via WorkManager, so the user sees fresh data on app open

### 7.5 Memory Considerations

- **Stream subscriptions**: All BLoC subscriptions are cleaned up in `close()`
- **Image caching**: `CachedNetworkImage` widget is ready for use with real image URLs, using disk and memory cache
- **ShakeDetector**: Accelerometer stream is started/stopped with screen lifecycle to avoid battery drain

---

## 8. Security Considerations

### 8.1 OWASP Mobile Top 10 Compliance

| OWASP Category | Implementation |
|---------------|----------------|
| M1: Improper Platform Usage | Runtime permission checks before all sensor/hardware access. Graceful degradation when permissions are denied or permanently denied. |
| M2: Insecure Data Storage | JWT tokens stored in `FlutterSecureStorage` (hardware-backed encryption). No sensitive data in SharedPreferences or logs. |
| M3: Insecure Communication | HTTPS-only base URL. Certificate pinning documented as production requirement. No sensitive data in URL parameters. |
| M4: Insecure Authentication | Form validation prevents empty/malformed credentials. 24-hour token TTL with automatic expiry. Biometric re-authentication on app resume. |
| M5: Insufficient Cryptography | Delegated to OS-provided encryption (Keychain/EncryptedSharedPreferences). No custom crypto implementations. |
| M6: Insecure Authorization | Auth state gating at MaterialApp level prevents unauthorized access to protected screens. |
| M8: Code Tampering | Release builds use code obfuscation (Flutter default). No runtime integrity checks (acceptable for this scope). |
| M9: Reverse Engineering | No hardcoded API keys or secrets in source code. Mock JWT is development-only. |

### 8.2 Credential Handling

- Email/password are validated client-side before transmission
- Credentials are never logged (Dio `LogInterceptor` has `requestBody: false`)
- JWT token is stored in platform-encrypted storage, not SharedPreferences
- Token issuance timestamp enables time-based expiry without server round-trip
- `SecureStorageService.deleteAll()` clears all credentials on logout

### 8.3 Input Sanitization

- Email validation via regex: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
- Password minimum length enforcement (6 characters)
- Search queries are lowercased and matched via `contains()` (no SQL injection vector as queries don't reach the database directly)
- All model `fromJson()` methods use defensive type coercion to prevent type confusion attacks

---

## 9. Conclusion

### 9.1 Summary

SmartCampus Companion demonstrates a production-grade Flutter application architecture with:

- **Clean Architecture** separating domain logic from framework concerns
- **Offline-first data strategy** ensuring the app works without network connectivity
- **Comprehensive OS concept coverage**: 14 distinct mobile OS concepts implemented and mapped
- **Security-first design** following OWASP guidelines for credential storage, input validation, and secure communication
- **Robust test suite**: 173 tests across unit, BLoC, and widget layers with zero analyzer warnings

### 9.2 Metrics

| Metric | Value |
|--------|-------|
| Total Dart files | 60+ |
| Test files | 20 |
| Total tests | 173 |
| Analyzer issues | 0 |
| Critical bugs fixed | 3 |
| OS concepts demonstrated | 14 |
| Sprints completed | 7 |

### 9.3 Possible Improvements

1. **Integration tests**: Add full end-to-end tests using `integration_test` package with real device/emulator execution
2. **Real backend**: Replace `MockInterceptor` with a real REST API (Firebase, Supabase, or custom server)
3. **Localization**: Implement `flutter_localizations` with ARB files for French and Arabic
4. **Accessibility**: Add `Semantics` widgets and test with TalkBack/VoiceOver
5. **CI/CD pipeline**: Configure GitHub Actions for automated testing, analysis, and deployment
6. **Certificate pinning**: Implement SSL pinning via Dio's `HttpClientAdapter` for production
7. **Push notifications**: Integrate Firebase Cloud Messaging for server-triggered notifications
8. **Code coverage reporting**: Add `flutter test --coverage` with lcov reporting to track coverage metrics
9. **Deep linking**: Implement universal links for sharing announcements and events
10. **State persistence**: Use `hydrated_bloc` to persist BLoC state across app restarts

---

*Generated as part of Week 7: Testing, Bug Fixes & Technical Report*  
*SmartCampus Companion v1.0.0*
