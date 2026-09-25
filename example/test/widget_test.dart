import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dynamic_widgets_example/main.dart';

void main() {
  testWidgets('builder starts empty, has IDE panels, and exports JSON', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const BuilderApp());

    // Menu bar, sidebars and console are present.
    expect(find.text('File'), findsOneWidget);
    expect(find.text('WIDGETS'), findsOneWidget);
    expect(find.text('Outline'), findsOneWidget);
    expect(find.text('Inspector'), findsOneWidget);
    expect(find.text('CONSOLE'), findsOneWidget);
    expect(find.text('JSON'), findsOneWidget);
    // Empty by default.
    expect(find.textContaining('Empty screen'), findsOneWidget);

    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export JSON…'));
    await tester.pumpAndSettle();

    expect(find.text('{}'), findsOneWidget);
  });
}
