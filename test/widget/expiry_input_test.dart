import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/features/common/expiry_input.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

void main() {
  final today = DateTime(2026, 10, 17);
  ExpiryDate? latest;
  var calls = 0;

  Future<void> pump(
    WidgetTester tester, {
    ExpiryDate? initial,
    String? errorText,
  }) async {
    latest = null;
    calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExpiryInput(
              today: today,
              initial: initial,
              errorText: errorText,
              onChanged: (v) {
                latest = v;
                calls++;
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> type(WidgetTester tester, String key, String text) async {
    await tester.enterText(find.byKey(Key(key)), text);
    await tester.pump();
  }

  bool hasFocus(WidgetTester tester, String key) {
    final field = tester.widget<TextField>(find.byKey(Key(key)));
    return field.focusNode!.hasFocus;
  }

  testWidgets('month/year resolves to the last day and shows it', (t) async {
    await pump(t);
    expect(find.byKey(const Key('expiry-resolved')), findsNothing);
    await type(t, 'expiry-month', '08');
    await type(t, 'expiry-year', '2027');
    expect(latest?.toIso(), '2027-08-31');
    expect(latest?.precision, ExpiryPrecision.month);
    expect(find.text('Expires Aug 31, 2027'), findsOneWidget);
    expect(find.byKey(const Key('expiry-warning')), findsNothing);
  });

  testWidgets('two-digit year is 20YY', (t) async {
    await pump(t);
    await type(t, 'expiry-month', '2');
    await type(t, 'expiry-year', '28');
    expect(latest?.toIso(), '2028-02-29');
  });

  testWidgets('focus advances from month to year automatically', (t) async {
    await pump(t);
    await t.tap(find.byKey(const Key('expiry-month')));
    await t.pump();
    expect(hasFocus(t, 'expiry-month'), isTrue);
    await type(t, 'expiry-month', '08');
    expect(hasFocus(t, 'expiry-year'), isTrue);
  });

  testWidgets('a month digit of 2-9 advances immediately; 1 waits', (t) async {
    await pump(t);
    await t.tap(find.byKey(const Key('expiry-month')));
    await type(t, 'expiry-month', '1');
    expect(hasFocus(t, 'expiry-month'), isTrue, reason: '1 may become 10-12');
    await type(t, 'expiry-month', '8');
    expect(hasFocus(t, 'expiry-year'), isTrue);
  });

  testWidgets('reports null while incomplete or invalid', (t) async {
    await pump(t);
    await type(t, 'expiry-month', '08');
    expect(latest, isNull);
    await type(t, 'expiry-year', '2027');
    expect(latest, isNotNull);
    await type(t, 'expiry-month', '13');
    expect(latest, isNull);
    expect(find.byKey(const Key('expiry-error')), findsOneWidget);
    expect(find.text('That is not a valid date'), findsOneWidget);
  });

  testWidgets('warns, without blocking, about a past expiry', (t) async {
    await pump(t);
    await type(t, 'expiry-month', '01');
    await type(t, 'expiry-year', '2026');
    expect(latest?.toIso(), '2026-01-31');
    expect(find.byKey(const Key('expiry-warning')), findsOneWidget);
    expect(find.text('This date is already in the past'), findsOneWidget);
  });

  testWidgets('warns about an expiry more than ten years away', (t) async {
    await pump(t);
    await type(t, 'expiry-month', '12');
    await type(t, 'expiry-year', '2040');
    expect(latest, isNotNull);
    expect(find.byKey(const Key('expiry-warning')), findsOneWidget);
  });

  testWidgets('exact-date toggle adds a day field and exact precision', (
    t,
  ) async {
    await pump(t);
    expect(find.byKey(const Key('expiry-day')), findsNothing);
    await t.tap(find.byKey(const Key('expiry-exact-toggle')));
    await t.pump();
    expect(find.byKey(const Key('expiry-day')), findsOneWidget);
    await type(t, 'expiry-day', '15');
    await type(t, 'expiry-month', '03');
    await type(t, 'expiry-year', '2027');
    expect(latest?.toIso(), '2027-03-15');
    expect(latest?.precision, ExpiryPrecision.day);
    expect(find.text('Expires Mar 15, 2027'), findsOneWidget);
  });

  testWidgets('exact mode rejects an impossible day', (t) async {
    await pump(t);
    await t.tap(find.byKey(const Key('expiry-exact-toggle')));
    await t.pump();
    await type(t, 'expiry-day', '31');
    await type(t, 'expiry-month', '04');
    await type(t, 'expiry-year', '2027');
    expect(latest, isNull);
    expect(find.byKey(const Key('expiry-error')), findsOneWidget);
  });

  testWidgets('prefills from an initial value', (t) async {
    await pump(t, initial: ExpiryDate.monthYear(2027, 8));
    expect(find.text('08'), findsOneWidget);
    expect(find.text('2027'), findsOneWidget);
    expect(find.text('Expires Aug 31, 2027'), findsOneWidget);
    expect(find.byKey(const Key('expiry-day')), findsNothing);

    // Unmount first so the new initial value builds a fresh State.
    await t.pumpWidget(const SizedBox());
    await pump(t, initial: ExpiryDate.day(2027, 3, 5));
    expect(find.byKey(const Key('expiry-day')), findsOneWidget);
  });

  testWidgets('shows the parent form error until a valid date is typed', (
    t,
  ) async {
    await pump(t, errorText: 'Enter the expiry date');
    expect(find.text('Enter the expiry date'), findsOneWidget);
    await type(t, 'expiry-month', '08');
    await type(t, 'expiry-year', '2027');
    // Parent normally clears it; the widget stops showing it once resolved.
    expect(find.text('Enter the expiry date'), findsNothing);
    expect(calls, greaterThan(0));
  });

  testWidgets('digits only and length limits', (t) async {
    await pump(t);
    await type(t, 'expiry-month', 'ab12345');
    final month = t.widget<TextField>(find.byKey(const Key('expiry-month')));
    expect(month.controller!.text, '12');
  });
}
