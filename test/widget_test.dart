import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/app.dart';

const Size _phoneSize = Size(420, 900);

Future<void> _pumpApp(
  WidgetTester tester, {
  Size size = _phoneSize,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const FieldInspectionApp());
  await tester.pumpAndSettle();
}

Future<void> _openFirstInspection(WidgetTester tester) async {
  final button = find.text('Buka Form Inspeksi').first;
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();

  await tester.tap(button);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Lets the geolocator timeout and any snack-bar timer finish so the test
/// leaves no pending timers behind.
Future<void> _drainTimers(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 26));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUp(() {
    debugDefaultTargetPlatformOverride = null;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('monitoring dashboard renders customers and actions', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(find.text('Inspeksi Lapangan'), findsOneWidget);
    expect(find.text('Ahmad Fauzi'), findsOneWidget);
    expect(find.text('512300847291'), findsOneWidget);
    expect(find.text('Sync OK'), findsOneWidget);
    expect(find.text('Buka Form Inspeksi'), findsWidgets);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.text('Monitoring'), findsOneWidget);
    expect(find.text('Peta'), findsOneWidget);
  });

  testWidgets('save is blocked until required inspection fields are complete', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await _pumpApp(tester);
    await _openFirstInspection(tester);

    expect(find.text('Form Inspeksi'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
    expect(find.text('Simpan Inspeksi'), findsOneWidget);

    await tester.tap(find.text('Simpan Inspeksi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Lengkapi semua field wajib (*) sebelum menyimpan inspeksi.'),
      findsOneWidget,
    );
    expect(find.text('Form Inspeksi'), findsOneWidget);

    await _drainTimers(tester);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('search filters customers by name', (tester) async {
    await _pumpApp(tester);

    await tester.enterText(find.byType(TextField).first, 'Siti');
    await tester.pumpAndSettle();

    expect(find.text('Siti Rahmawati'), findsOneWidget);
    expect(find.text('Ahmad Fauzi'), findsNothing);
  });

  testWidgets('status chips filter customers and use live counts', (
    tester,
  ) async {
    await _pumpApp(tester);

    final chipScrollable = find
        .ancestor(
          of: find.text('Semua (8)'),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Selesai (3)'),
      150,
      scrollable: chipScrollable,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Selesai (3)'));
    await tester.pumpAndSettle();

    expect(find.text('Siti Rahmawati'), findsOneWidget);
    expect(find.text('Ahmad Fauzi'), findsNothing);
  });

  testWidgets('maps tab is reachable from bottom navigation', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await _pumpApp(tester, size: const Size(360, 800));

    await tester.tap(find.text('Peta'));
    await tester.pumpAndSettle();

    expect(find.text('Peta Pelanggan'), findsOneWidget);
    expect(find.text('Pelanggan di peta'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('long form fits a narrow phone and reaches every section', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await _pumpApp(tester, size: const Size(360, 800));
    await _openFirstInspection(tester);

    expect(find.text('Form Inspeksi'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final formScrollable = find.byType(Scrollable).first;
    for (final title in const [
      'Titik Koordinat Petugas',
      'Bukti Foto Lapangan',
      'Hasil Inspeksi Lapangan',
    ]) {
      await tester.scrollUntilVisible(
        find.text(title),
        400,
        scrollable: formScrollable,
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text(title), findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    await _drainTimers(tester);
    debugDefaultTargetPlatformOverride = null;
  });
}
