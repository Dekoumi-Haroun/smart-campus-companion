import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:smart_campus/core/services/shake_detector.dart';

void main() {
  group('ShakeDetector', () {
    test('fires onShake when acceleration exceeds threshold', () async {
      final controller = StreamController<AccelerometerEvent>();
      final detector = ShakeDetector(
        shakeThreshold: 10.0,
        cooldown: const Duration(milliseconds: 100),
        accelerometerStream: controller.stream,
      );

      int shakeCount = 0;
      detector.onShake.listen((_) => shakeCount++);
      detector.start();

      // Send a strong shake event (magnitude ~30, well above 9.8 + 10)
      controller.add(AccelerometerEvent(25.0, 0.0, 9.8, DateTime.now()));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(shakeCount, 1);

      detector.dispose();
      await controller.close();
    });

    test('does not fire when acceleration is below threshold', () async {
      final controller = StreamController<AccelerometerEvent>();
      final detector = ShakeDetector(
        shakeThreshold: 15.0,
        cooldown: const Duration(milliseconds: 100),
        accelerometerStream: controller.stream,
      );

      int shakeCount = 0;
      detector.onShake.listen((_) => shakeCount++);
      detector.start();

      // Normal gravity-only reading (magnitude ~9.8, threshold not exceeded)
      controller.add(AccelerometerEvent(0.0, 0.0, 9.8, DateTime.now()));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(shakeCount, 0);

      detector.dispose();
      await controller.close();
    });

    test('respects cooldown between shakes', () async {
      final controller = StreamController<AccelerometerEvent>();
      final detector = ShakeDetector(
        shakeThreshold: 10.0,
        cooldown: const Duration(milliseconds: 500),
        accelerometerStream: controller.stream,
      );

      int shakeCount = 0;
      detector.onShake.listen((_) => shakeCount++);
      detector.start();

      // First shake
      controller.add(AccelerometerEvent(25.0, 0.0, 9.8, DateTime.now()));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(shakeCount, 1);

      // Second shake immediately — should be ignored (within cooldown)
      controller.add(AccelerometerEvent(25.0, 0.0, 9.8, DateTime.now()));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(shakeCount, 1); // Still 1

      detector.dispose();
      await controller.close();
    });

    test('fires again after cooldown expires', () async {
      final controller = StreamController<AccelerometerEvent>();
      final detector = ShakeDetector(
        shakeThreshold: 10.0,
        cooldown: const Duration(milliseconds: 100),
        accelerometerStream: controller.stream,
      );

      int shakeCount = 0;
      detector.onShake.listen((_) => shakeCount++);
      detector.start();

      // First shake
      controller.add(AccelerometerEvent(25.0, 0.0, 9.8, DateTime.now()));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(shakeCount, 1);

      // Wait for cooldown
      await Future.delayed(const Duration(milliseconds: 150));

      // Second shake — should fire
      controller.add(AccelerometerEvent(25.0, 0.0, 9.8, DateTime.now()));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(shakeCount, 2);

      detector.dispose();
      await controller.close();
    });

    test('stop prevents further shake events', () async {
      final controller = StreamController<AccelerometerEvent>();
      final detector = ShakeDetector(
        shakeThreshold: 10.0,
        cooldown: const Duration(milliseconds: 100),
        accelerometerStream: controller.stream,
      );

      int shakeCount = 0;
      detector.onShake.listen((_) => shakeCount++);
      detector.start();

      // Shake while running
      controller.add(AccelerometerEvent(25.0, 0.0, 9.8, DateTime.now()));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(shakeCount, 1);

      // Stop
      detector.stop();

      // Shake again — should not fire
      controller.add(AccelerometerEvent(25.0, 0.0, 9.8, DateTime.now()));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(shakeCount, 1);

      detector.dispose();
      await controller.close();
    });

    test('detects shake on Y axis', () async {
      final controller = StreamController<AccelerometerEvent>();
      final detector = ShakeDetector(
        shakeThreshold: 10.0,
        cooldown: const Duration(milliseconds: 100),
        accelerometerStream: controller.stream,
      );

      int shakeCount = 0;
      detector.onShake.listen((_) => shakeCount++);
      detector.start();

      // Strong Y-axis shake
      controller.add(AccelerometerEvent(0.0, 25.0, 9.8, DateTime.now()));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(shakeCount, 1);

      detector.dispose();
      await controller.close();
    });
  });
}
