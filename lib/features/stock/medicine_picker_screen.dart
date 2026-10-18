import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/features/common/search_field.dart';
import 'package:pharmacy_expiry_tracker/features/stock/medicine_tile.dart';
import 'package:pharmacy_expiry_tracker/features/stock/stock_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// First step of "Add stock": choose a medicine (or create one), then receive
/// a batch for it.
class MedicinePickerScreen extends ConsumerStatefulWidget {
  const MedicinePickerScreen({super.key});

  @override
  ConsumerState<MedicinePickerScreen> createState() =>
      _MedicinePickerScreenState();
}

class _MedicinePickerScreenState extends ConsumerState<MedicinePickerScreen> {
  String _query = '';

  Future<void> _createNew() async {
    final id = await context.push<String>('${Routes.stock}/medicine/new');
    if (id != null && mounted) {
      await context.push('${Routes.stock}/medicine/$id/batch/new');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = ref.watch(
      medicineListProvider((query: _query, includeArchived: false)),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.stockAddStock)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchField(
              key: const Key('picker-search'),
              autofocus: true,
              hintText: l10n.stockSearchHint,
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
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
                  onTap: () => context.push(
                    '${Routes.stock}/medicine/${items[i].medicine.id}/batch/new',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
