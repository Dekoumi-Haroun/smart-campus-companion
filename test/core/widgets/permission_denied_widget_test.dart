import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_campus/core/services/permission_service.dart';
import 'package:smart_campus/core/widgets/permission_denied_widget.dart';

/// Fake PermissionService that tracks openSettings calls.
class FakePermissionService extends PermissionService {
  bool settingsOpened = false;

  @override
  Future<PermissionStatus> checkStatus(Permission permission) async {
    return PermissionStatus.denied;
  }

  @override
  Future<PermissionStatus> requestPermission(Permission permission) async {
    return PermissionStatus.denied;
  }

  @override
  Future<bool> isPermanentlyDenied(Permission permission) async {
    return false;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened = true;
    return true;
  }
}

void main() {
  group('PermissionDeniedWidget', () {
    testWidgets('shows icon, title, and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PermissionDeniedWidget(
              icon: Icons.camera_alt_rounded,
              message: 'Camera access is needed to attach photos.',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
      expect(find.text('Permission Required'), findsOneWidget);
      expect(
        find.text('Camera access is needed to attach photos.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'shows Retry button when not permanently denied and onRetry provided',
      (tester) async {
        bool retried = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PermissionDeniedWidget(
                icon: Icons.location_on_rounded,
                message: 'Location access is needed.',
                onRetry: () => retried = true,
              ),
            ),
          ),
        );

        expect(find.text('Retry'), findsOneWidget);
        expect(find.text('Open Settings'), findsNothing);

        await tester.tap(find.text('Retry'));
        expect(retried, isTrue);
      },
    );

    testWidgets('shows Open Settings button when permanently denied', (
      tester,
    ) async {
      final fakeService = FakePermissionService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionDeniedWidget(
              icon: Icons.camera_alt_rounded,
              message: 'Camera access is needed.',
              isPermanentlyDenied: true,
              permissionService: fakeService,
            ),
          ),
        ),
      );

      // Should show "Open Settings", not "Retry"
      expect(find.text('Open Settings'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);

      // Should show permanently denied hint
      expect(
        find.text(
          'Permission was permanently denied. Please enable it in your device settings.',
        ),
        findsOneWidget,
      );

      // Tap should open settings
      await tester.tap(find.text('Open Settings'));
      await tester.pump();
      expect(fakeService.settingsOpened, isTrue);
    });

    testWidgets(
      'shows no action button when not permanently denied and no onRetry',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PermissionDeniedWidget(
                icon: Icons.bluetooth_rounded,
                message: 'Bluetooth access is needed.',
              ),
            ),
          ),
        );

        expect(find.text('Open Settings'), findsNothing);
        expect(find.text('Retry'), findsNothing);
      },
    );

    testWidgets('does not show permanently denied hint when not permanent', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionDeniedWidget(
              icon: Icons.location_on_rounded,
              message: 'Location access is needed.',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(
        find.text(
          'Permission was permanently denied. Please enable it in your device settings.',
        ),
        findsNothing,
      );
    });

    testWidgets('uses correct error styling for icon container', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PermissionDeniedWidget(
              icon: Icons.camera_alt_rounded,
              message: 'Test message',
            ),
          ),
        ),
      );

      // Find the decorated container holding the icon
      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.camera_alt_rounded),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });
  });
}
