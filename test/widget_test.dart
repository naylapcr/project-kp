import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/app.dart';

void main() {
  testWidgets('monitoring dashboard renders customers and actions', (
    tester,
  ) async {
    await tester.pumpWidget(const FieldInspectionApp());
    await tester.pumpAndSettle();

    expect(find.text('Monitoring'), findsAtLeastNWidgets(1));
    expect(find.text('AHMAD FAUZI'), findsOneWidget);
    expect(find.text('512300847291'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsWidgets);
    expect(find.byIcon(Icons.location_on_outlined), findsWidgets);
    expect(find.text('Maps'), findsOneWidget);
  });

  testWidgets('save is blocked until required inspection fields are complete', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await tester.pumpWidget(const FieldInspectionApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();

    expect(find.text('Belum Dikerjakan Form'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('Lengkapi semua field wajib (*) sebelum menyimpan inspeksi.'),
      findsOneWidget,
    );
    expect(find.text('Belum Dikerjakan Form'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('search filters customers by name', (tester) async {
    await tester.pumpWidget(const FieldInspectionApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Siti');
    await tester.pumpAndSettle();

    expect(find.text('Siti Rahmawati'), findsOneWidget);
    expect(find.text('Ahmad Fauzi'), findsNothing);
  });

  testWidgets('maps tab is reachable from bottom navigation', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await tester.pumpWidget(const FieldInspectionApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    expect(find.text('Maps'), findsWidgets);
    expect(find.text('Pelanggan di peta'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('long form fits a narrow phone and reaches location section', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FieldInspectionApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Pelacakan Lokasi'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Pelacakan Lokasi'), findsOneWidget);
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });
}
