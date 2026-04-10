import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_campus/core/constants/app_strings.dart';
import 'package:smart_campus/core/widgets/common_widgets.dart';
import 'package:smart_campus/presentation/blocs/connectivity/connectivity_cubit.dart';
import 'package:smart_campus/presentation/blocs/connectivity/connectivity_state.dart';

/// Testable subclass that exposes emit for driving state in widget tests.
class TestConnectivityCubit extends ConnectivityCubit {
  TestConnectivityCubit() : super();

  void setOffline() => emit(const ConnectivityOffline());
  void setOnline() => emit(const ConnectivityOnline());
}

void main() {
  group('OfflineBanner', () {
    testWidgets('shows offline banner when ConnectivityOffline', (
      tester,
    ) async {
      final cubit = TestConnectivityCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ConnectivityCubit>.value(
            value: cubit,
            child: const Scaffold(body: Column(children: [OfflineBanner()])),
          ),
        ),
      );

      cubit.setOffline();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text(AppStrings.offlineBanner), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

      await cubit.close();
    });

    testWidgets('hides banner when connectivity restored', (tester) async {
      final cubit = TestConnectivityCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ConnectivityCubit>.value(
            value: cubit,
            child: const Scaffold(body: Column(children: [OfflineBanner()])),
          ),
        ),
      );

      // Start offline.
      cubit.setOffline();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text(AppStrings.offlineBanner), findsOneWidget);

      // Go online — AnimatedSwitcher replaces with SizedBox.shrink.
      cubit.setOnline();
      // Pump multiple frames to let the AnimatedSwitcher fully transition.
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // After animation completes, the offline banner text should be gone.
      expect(find.text(AppStrings.offlineBanner), findsNothing);

      await cubit.close();
    });

    testWidgets('does not show banner when initially online', (tester) async {
      final cubit = TestConnectivityCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ConnectivityCubit>.value(
            value: cubit,
            child: const Scaffold(body: Column(children: [OfflineBanner()])),
          ),
        ),
      );

      await tester.pump();
      expect(find.text(AppStrings.offlineBanner), findsNothing);

      await cubit.close();
    });
  });
}
