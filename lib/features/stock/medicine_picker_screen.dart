import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/features/common/search_field.dart';
import 'package:pharmacy_expiry_tracker/features/scan/scan_flow.dart';
import 'package:pharmacy_expiry_tracker/features/stock/medicine_tile.dart';
import 'package:pharmacy_expiry_tracker/features/stock/stock_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// First step of "Add stock": choose a medicine (or create one), then receive
/// a batch for it.
class MedicinePickerScreen extends ConsumerStatefulWidget {
  const MedicinePickerScreen({this.choose = false, super.key});

  /// Return the chosen medicine's id instead of starting "receive a batch".
  final bool choose;

  @override
  ConsumerState<MedicinePickerScreen> createState() =>
      _MedicinePickerScreenState();
}

class _MedicinePickerScreenState extends ConsumerState<MedicinePickerScreen> {
  String _query = '';

  Future<void> _open(String id) async {
    if (widget.choose) {
      context.pop(id);
    } else {
      await context.push('${Routes.stock}/medicine/$id/batch/new');
    }
  }

  Future<void> _scan() async {
    final id = await scanToMedicineId(context, ref);
    if (id != null && mounted) await _open(id);
  }

  Future<void> _createNew() async {
    final id = await context.push<String>('${Routes.stock}/medicine/new');
    if (id != null && mounted) await _open(id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = ref.watch(
      medicineListProvider((query: _query, includeArchived: false)),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.choose ? l10n.pickerChooseTitle : l10n.stockAddStock,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchField(
              key: const Key('picker-search'),
              autofocus: true,
              hintText: l10n.stockSearchHint,
              onScan: _scan,
              scanTooltip: l10n.scanButton,
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          if (!widget.choose)
            ListTile(
              key: const Key('picker-delivery'),
              leading: const Icon(Icons.local_shipping_outlined),
              title: Text(l10n.receiveDeliveryAction),
              onTap: () => context.push(Routes.receiveDelivery),
            ),
          ListTile(
            key: const Key('picker-create'),
            leading: const Icon(Icons.add_circle_outline),
            title: Text(l10n.medicineNew),
            onTap: _createNew,
          ),
          const Divider(height: 1),
          Expanded(
            child: list.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.errorGeneric)),
              data: (items) => ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) => MedicineTile(
                  summary: items[i],
                  onTap: () => _open(items[i].medicine.id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
