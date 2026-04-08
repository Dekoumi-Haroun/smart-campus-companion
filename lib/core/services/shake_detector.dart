import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

/// Detects device shakes using the accelerometer.
///
/// Fires [onShake] when the device acceleration magnitude exceeds
/// [shakeThreshold] on any axis, respecting a [cooldown] between events.
class ShakeDetector {
  /// Minimum acceleration magnitude (m/s²) to trigger a shake.
  final double shakeThreshold;

  /// Minimum duration between consecutive shake events.
  final Duration cooldown;

  /// Optional stream to inject for testing. If null, uses the real
  /// accelerometer stream from `sensors_plus`.
  final Stream<AccelerometerEvent>? accelerometerStream;

  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime _lastShakeTime = DateTime(2000);
  final _shakeController = StreamController<void>.broadcast();

  ShakeDetector({
    this.shakeThreshold = 15.0,
    this.cooldown = const Duration(seconds: 2),
    this.accelerometerStream,
  });

  /// Stream that emits when a shake is detected.
  Stream<void> get onShake => _shakeController.stream;

  /// Start listening to accelerometer events.
  void start() {
    _subscription?.cancel();
    final stream =
        accelerometerStream ??
        accelerometerEventStream(
          samplingPeriod: const Duration(milliseconds: 100),
        );
    _subscription = stream.listen(_onAccelerometerEvent);
  }

  /// Stop listening to accelerometer events.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Dispose of resources.
  void dispose() {
    stop();
    _shakeController.close();
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    // Calculate magnitude (including gravity ~9.8, so we subtract it).
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Subtract gravity baseline and check threshold.
    if ((magnitude - 9.8).abs() > shakeThreshold) {
      final now = DateTime.now();
      if (now.difference(_lastShakeTime) >= cooldown) {
        _lastShakeTime = now;
        _shakeController.add(null);
      }
    }
  }
}
