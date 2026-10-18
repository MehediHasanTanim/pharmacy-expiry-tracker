import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/features/scan/barcode_scan_screen.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

enum _UnknownChoice { link, create }

/// Scans a barcode and turns it into a medicine id (SCN-2, MED-3):
///
///  * known barcode: that medicine;
///  * unknown barcode: asks whether to link it to an existing medicine or
///    create a new one, does so, and returns that medicine;
///  * cancelled or unreadable: null.
Future<String?> scanToMedicineId(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final service = ref.read(barcodeServiceProvider);

  final code = await ref.read(barcodeScanProvider)(context);
  if (code == null || !context.mounted) return null;

  try {
    final found = await service.lookup(code);
    if (found != null) return found.id;
  } on ValidationException {
    messenger.showSnackBar(SnackBar(content: Text(l10n.scanInvalid)));
    return null;
  }
  if (!context.mounted) return null;

  final choice = await showModalBottomSheet<_UnknownChoice>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(l10n.scanUnknownTitle),
            subtitle: Text(l10n.scanUnknownBody(code.trim())),
          ),
          ListTile(
            key: const Key('scan-link-existing'),
            leading: const Icon(Icons.link),
            title: Text(l10n.scanLinkExisting),
            onTap: () => Navigator.pop(ctx, _UnknownChoice.link),
          ),
          ListTile(
            key: const Key('scan-create-new'),
            leading: const Icon(Icons.add_circle_outline),
            title: Text(l10n.scanCreateNew),
            onTap: () => Navigator.pop(ctx, _UnknownChoice.create),
          ),
        ],
      ),
    ),
  );
  if (choice == null || !context.mounted) return null;

  switch (choice) {
    case _UnknownChoice.create:
      // The form links the barcode once the medicine is saved.
      return context.push<String>(
        Uri(
          path: '${Routes.stock}/medicine/new',
          queryParameters: {'barcode': code},
        ).toString(),
      );
    case _UnknownChoice.link:
      final id = await context.push<String>('${Routes.stock}/pick?choose=1');
      if (id == null || !context.mounted) return null;
      return await linkBarcode(context, ref, id, code) ? id : null;
  }
}

/// Links [code] to [medicineId], telling the user if another medicine has it.
/// Returns whether the barcode now belongs to [medicineId].
Future<bool> linkBarcode(
  BuildContext context,
  WidgetRef ref,
  String medicineId,
  String code,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final medicines = ref.read(medicineRepositoryProvider);
  try {
    await ref.read(barcodeServiceProvider).link(medicineId, code);
    final m = await medicines.getById(medicineId);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.scanLinked(m?.displayName ?? ''))),
    );
    return true;
  } on BarcodeTakenException catch (e) {
    final other = await medicines.getById(e.medicineId);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.scanTakenBy(other?.displayName ?? ''))),
    );
    return false;
  } on ValidationException {
    messenger.showSnackBar(SnackBar(content: Text(l10n.scanInvalid)));
    return false;
  }
}
