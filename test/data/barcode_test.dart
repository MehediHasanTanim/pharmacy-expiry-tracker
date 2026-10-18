import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/barcode_usecases.dart';

import '../support/test_env.dart';

void main() {
  late TestEnv env;
  late String napa;
  late String amoxil;

  setUp(() async {
    env = TestEnv();
    napa = await env.medicine(brand: 'Napa', strength: '500 mg');
    amoxil = await env.medicine(brand: 'Amoxil', strength: '250 mg');
  });
  tearDown(() => env.dispose());

  test('values are cleaned and bounded', () {
    expect(normalizeBarcode(' 8901 2345\n'), '89012345');
    expect(() => normalizeBarcode('  \t'), throwsA(isA<ValidationException>()));
    expect(
      () => normalizeBarcode('1' * (maxBarcodeLength + 1)),
      throwsA(isA<ValidationException>()),
    );
    expect(normalizeBarcode('1' * maxBarcodeLength), hasLength(128));
  });

  test(
    'an unknown barcode finds nothing; a linked one finds the medicine',
    () async {
      expect(await env.barcodes.lookup('8901234567890'), isNull);
      await env.barcodes.link(napa, '8901234567890', symbology: 'ean13');
      final found = await env.barcodes.lookup(' 8901234567890 ');
      expect(found!.id, napa);
      expect(found.displayName, 'Napa 500 mg');
    },
  );

  test('one medicine can have several barcodes', () async {
    await env.barcodes.link(napa, '111');
    await env.barcodes.link(napa, '222');
    final all = await env.barcodesRepo.watchForMedicine(napa).first;
    expect(all.map((b) => b.value), ['111', '222']);
    expect((await env.barcodes.lookup('222'))!.id, napa);
  });

  test('linking again is harmless; another medicine cannot take it', () async {
    final first = await env.barcodes.link(napa, '555');
    final again = await env.barcodes.link(napa, '555');
    expect(again.id, first.id);
    await expectLater(
      env.barcodes.link(amoxil, '555'),
      throwsA(
        isA<BarcodeTakenException>().having(
          (e) => e.medicineId,
          'medicineId',
          napa,
        ),
      ),
    );
    expect((await env.barcodes.lookup('555'))!.id, napa);
  });

  test('unlinking frees the value for another medicine', () async {
    final b = await env.barcodes.link(napa, '777');
    await env.barcodes.unlink(b);
    expect(await env.barcodes.lookup('777'), isNull);
    await env.barcodes.link(amoxil, '777');
    expect((await env.barcodes.lookup('777'))!.id, amoxil);
  });

  test('unknown medicine is refused', () async {
    await expectLater(
      env.barcodes.link('ghost', '1'),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('changes are announced', () async {
    final seen = <String?>[];
    final sub = env.bus.changes.listen((c) => seen.add(c.medicineId));
    await env.barcodes.link(napa, '9');
    await Future<void>.delayed(Duration.zero);
    expect(seen, [napa]);
    await sub.cancel();
  });
}
