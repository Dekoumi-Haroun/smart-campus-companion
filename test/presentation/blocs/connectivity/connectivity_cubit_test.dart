import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/presentation/blocs/connectivity/connectivity_cubit.dart';
import 'package:smart_campus/presentation/blocs/connectivity/connectivity_state.dart';

/// Fake [Connectivity] that lets tests control connectivity results.
class FakeConnectivity implements Connectivity {
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();
  List<ConnectivityResult> _current = [ConnectivityResult.wifi];

  void setResult(List<ConnectivityResult> results) {
    _current = results;
    _controller.add(results);
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _current;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  void dispose() => _controller.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeConnectivity fakeConnectivity;

  setUp(() {
    fakeConnectivity = FakeConnectivity();
  });

  tearDown(() {
    fakeConnectivity.dispose();
  });

  group('ConnectivityCubit', () {
    test('initial state is online when wifi is available', () async {
      fakeConnectivity._current = [ConnectivityResult.wifi];
      final cubit = ConnectivityCubit(connectivity: fakeConnectivity);

      // Allow _checkInitial to complete.
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<ConnectivityOnline>());
      await cubit.close();
    });

    test('initial state is offline when no connectivity', () async {
      fakeConnectivity._current = [ConnectivityResult.none];
      final cubit = ConnectivityCubit(connectivity: fakeConnectivity);

      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<ConnectivityOffline>());
      await cubit.close();
    });

    test('emits offline when connectivity drops', () async {
      final cubit = ConnectivityCubit(connectivity: fakeConnectivity);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<ConnectivityOnline>());

      fakeConnectivity.setResult([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<ConnectivityOffline>());
      await cubit.close();
    });

    test('emits online when connectivity is restored', () async {
      fakeConnectivity._current = [ConnectivityResult.none];
      final cubit = ConnectivityCubit(connectivity: fakeConnectivity);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<ConnectivityOffline>());

      fakeConnectivity.setResult([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<ConnectivityOnline>());
      await cubit.close();
    });

    test('handles multiple connectivity changes in sequence', () async {
      final cubit = ConnectivityCubit(connectivity: fakeConnectivity);
      final states = <ConnectivityState>[];
      final sub = cubit.stream.listen(states.add);

      await Future<void>.delayed(Duration.zero);

      fakeConnectivity.setResult([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);

      fakeConnectivity.setResult([ConnectivityResult.mobile]);
      await Future<void>.delayed(Duration.zero);

      fakeConnectivity.setResult([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);

      // First emission is from _checkInitial (online), then the 3 changes.
      expect(states, [
        isA<ConnectivityOnline>(),
        isA<ConnectivityOffline>(),
        isA<ConnectivityOnline>(),
        isA<ConnectivityOffline>(),
      ]);

      await sub.cancel();
      await cubit.close();
    });
  });
}
