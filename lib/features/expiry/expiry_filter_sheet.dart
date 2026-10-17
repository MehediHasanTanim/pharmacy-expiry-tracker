import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/expiry.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/expiry/expiry_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

Future<void> showExpiryFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => const ExpiryFilterSheet(),
  );
}

/// Sort order and extra filters. The last selection is saved in settings, so
/// it is still there next time (S2-05).
class ExpiryFilterSheet extends ConsumerStatefulWidget {
  const ExpiryFilterSheet({super.key});

  @override
  ConsumerState<ExpiryFilterSheet> createState() => _ExpiryFilterSheetState();
}

class _ExpiryFilterSheetState extends ConsumerState<ExpiryFilterSheet> {
  late ExpirySort _sort;
  late String _category;
  late String _form;
  late bool _hideHandled;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider).value ?? const AppSettings();
    _sort = ExpirySort.fromStored(s.expirySort);
    _category = s.expiryCategory;
    _form = s.expiryForm;
    _hideHandled = s.expiryHideHandled;
  }

  void _reset() => setState(() {
    _sort = ExpirySort.soonest;
    _category = '';
    _form = '';
    _hideHandled = false;
  });

  Future<void> _apply() async {
    await ref
        .read(settingsRepositoryProvider)
        .update(
          (s) => s.copyWith(
            expirySort: _sort.stored,
            expiryCategory: _category,
            expiryForm: _form,
            expiryHideHandled: _hideHandled,
          ),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final categories = ref.watch(expiryCategoriesProvider).value ?? const [];
    // Keep a saved category selectable even if no medicine uses it any more.
    final categoryOptions = {
      if (_category.isNotEmpty) _category,
      ...categories,
    }.toList()..sort();

    String sortLabel(ExpirySort s) => switch (s) {
      ExpirySort.soonest => l10n.sortSoonest,
      ExpirySort.valueAtRisk => l10n.sortValue,
      ExpirySort.name => l10n.sortName,
    };

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.filterTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  key: const Key('filter-reset'),
                  onPressed: _reset,
                  child: Text(l10n.filterReset),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.filterSortBy, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            for (final s in ExpirySort.values)
              ListTile(
                key: Key('sort-${s.stored}'),
                contentPadding: EdgeInsets.zero,
                selected: _sort == s,
                leading: Icon(
                  _sort == s
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(sortLabel(s)),
                onTap: () => setState(() => _sort = s),
              ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: const Key('filter-category'),
              initialValue: _category,
              decoration: InputDecoration(
                labelText: l10n.filterCategory,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: '', child: Text(l10n.filterAll)),
                for (final c in categoryOptions)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => _category = v ?? ''),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('filter-form'),
              initialValue: _form,
              decoration: InputDecoration(
                labelText: l10n.filterForm,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: '', child: Text(l10n.filterAll)),
                for (final f in DosageForm.values)
                  DropdownMenuItem(
                    value: f.name,
                    child: Text(dosageFormLabel(l10n, f)),
                  ),
              ],
              onChanged: (v) => setState(() => _form = v ?? ''),
            ),
            SwitchListTile(
              key: const Key('filter-hide-handled'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.filterHideHandled),
              value: _hideHandled,
              onChanged: (v) => setState(() => _hideHandled = v),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('filter-apply'),
                onPressed: _apply,
                child: Text(l10n.filterApply),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
