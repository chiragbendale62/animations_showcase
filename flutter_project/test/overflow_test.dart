import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/main.dart';
import 'package:flutter_project/screens/explicit_controller.dart';
import 'package:flutter_project/screens/implicit_playground.dart';
import 'package:flutter_project/screens/isolate_lab_screen.dart';
import 'package:flutter_project/screens/physics_lab_screen.dart';
import 'package:flutter_project/screens/hero_showcase_screen.dart';

Future<void> pumpFrames(WidgetTester tester, {int frames = 3}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  final sizes = [
    const Size(320, 568),
    const Size(375, 667),
    const Size(768, 1024),
    const Size(1280, 800),
  ];

  for (final size in sizes) {
    testWidgets('Dashboard no overflow at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const AdvancedAnimationsApp());
      await pumpFrames(tester, frames: 5);

      expect(tester.takeException(), isNull);
    });

    testWidgets('ImplicitPlayground no overflow at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: ImplicitPlayground()),
      );
      await pumpFrames(tester, frames: 3);

      expect(tester.takeException(), isNull);
    });

    testWidgets('ExplicitController no overflow at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: ExplicitControllerScreen()),
      );
      await pumpFrames(tester, frames: 3);

      expect(tester.takeException(), isNull);
    });

    testWidgets('PhysicsLab no overflow at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: PhysicsLabScreen()),
      );
      await pumpFrames(tester, frames: 3);

      expect(tester.takeException(), isNull);
    });

    testWidgets('HeroShowcase no overflow at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: HeroShowcaseScreen()),
      );
      await pumpFrames(tester, frames: 3);

      expect(tester.takeException(), isNull);
    });

    testWidgets('IsolateLab no overflow at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: IsolateLabScreen()),
      );
      await pumpFrames(tester, frames: 3);

      expect(tester.takeException(), isNull);
    });
  }
}
