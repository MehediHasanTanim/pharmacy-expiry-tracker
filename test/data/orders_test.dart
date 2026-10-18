import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';

import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late String med;
  late String sup;

  setUp(() async {
    env = TestEnv();
    med = await env.medicine(
      brand: 'Napa',
      strength: '500 mg',
      reorderLevel: 20,
    );
    sup = await env.supplier();
    await env.addBatch(env.batchInput(med, quantity: 5));
    await env.settings.update(
      (s) => s.copyWith(
        digestEnabled: false,
        alertLeadDays: const [],
        backupReminderDays: 0,
      ),
    );
  });
  tearDown(() => env.dispose());

  Future<List<String>> keys() async => [
    for (final r in await env.alertStore.all())
      if (r.isPending && r.kind == AlertKind.reorder) r.key,
  ];

  Future<void> replan() async =>
      expect((await env.alertEngine.replan()).error, isNull);

  test('placing an order shows on the reorder list', () async {
    expect(
      (await env.reorderRepo
              .watchBelowLevel(today: DateTime(2026, 10, 17))
              .first)
          .single
          .order,
      isNull,
    );
    final o = await env.orders.place(
      med,
      quantity: 40,
      supplierId: sup,
      expectedOn: DateTime(2026, 10, 24),
    );
    expect(o.quantity, 40);
    final item =
        (await env.reorderRepo
                .watchBelowLevel(today: DateTime(2026, 10, 17))
                .first)
            .single;
    expect(item.order!.quantity, 40);
    expect(item.order!.supplierId, sup);
    expect(item.order!.dueOn, DateTime(2026, 10, 24));
  });

  test('reorder reminders pause while the order is on its way', () async {
    await replan();
    expect(await keys(), contains('reorder:2026-10-17'));

    await env.orders.place(
      med,
      quantity: 40,
      expectedOn: DateTime(2026, 10, 20),
    );
    await replan();
    final k = await keys();
    expect(k.where((x) => x.startsWith('reorder:')), isEmpty);
    // After the due day the order is chased, not reordered.
    expect(k.first, 'ordered:2026-10-21');
    expect(k, [
      'ordered:2026-10-21',
      'ordered:2026-10-24',
      'ordered:2026-10-27',
      'ordered:2026-10-30',
    ]);
    final late = env.plugin.scheduled.values.firstWhere(
      (n) => n.title.contains('late'),
    );
    expect(late.body, 'Napa 500 mg (40 ordered)');
  });

  test('without an expected date, an order is assumed due in a week', () async {
    await env.orders.place(med, quantity: 10);
    await replan();
    expect((await keys()).first, 'ordered:2026-10-25');
  });

  test('already late: chased from today', () async {
    await env.orders.place(
      med,
      quantity: 10,
      expectedOn: DateTime(2026, 10, 17),
    );
    env.clock.current = DateTime(2026, 10, 25, 8);
    await replan();
    expect((await keys()).first, 'ordered:2026-10-25');
  });

  test('receiving closes the order and returns it for pre-filling', () async {
    await env.orders.place(med, quantity: 40, supplierId: sup);
    final got = await env.orders.markReceived(med);
    expect(got.quantity, 40);
    expect(got.supplierId, sup);
    expect(await env.reorderRepo.getOpenOrder(med), isNull);
    await expectLater(
      env.orders.markReceived(med),
      throwsA(isA<NotFoundException>()),
    );
    // Still below level, so reminders resume.
    await replan();
    expect(await keys(), contains('reorder:2026-10-17'));
  });

  test(
    'cancelling the order resumes reminders; a new order replaces the old',
    () async {
      await env.orders.place(med, quantity: 10);
      await env.orders.place(med, quantity: 25);
      expect((await env.reorderRepo.getOpenOrder(med))!.quantity, 25);
      await env.orders.cancel(med);
      expect(await env.reorderRepo.getOpenOrder(med), isNull);
      await env.orders.cancel(med); // harmless when none
      await replan();
      expect(await keys(), contains('reorder:2026-10-17'));
    },
  );

  test('bad input is refused', () async {
    await expectLater(
      env.orders.place(med, quantity: 0),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      env.orders.place(med, quantity: 1, expectedOn: DateTime(2026, 10, 1)),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      env.orders.place('ghost', quantity: 1),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('a delivered chase reminder restarts the interval', () async {
    await env.orders.place(
      med,
      quantity: 10,
      expectedOn: DateTime(2026, 10, 17),
    );
    await replan();
    final first = (await env.alertStore.all()).firstWhere(
      (r) => r.key.startsWith('ordered:'),
    );
    env.clock.current = first.fireAt.add(const Duration(hours: 1));
    await replan();
    final next = (await keys()).first;
    expect(next, isNot(first.key));
  });
}
