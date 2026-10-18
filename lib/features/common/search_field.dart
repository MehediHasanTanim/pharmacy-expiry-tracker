import 'package:flutter/material.dart';

/// A search box. Built on [TextField] rather than Material's `SearchBar`
/// because screen readers and the tap-target guideline see `SearchBar`'s inner
/// text field as only one line tall; a [TextField] exposes its whole 56 dp box.
class SearchField extends StatelessWidget {
  const SearchField({
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.onSubmitted,
    this.onScan,
    this.scanTooltip,
    super.key,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  /// Shows a scan button at the end of the box (SCN-2).
  final VoidCallback? onScan;
  final String? scanTooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = controller;
    return TextField(
      controller: c,
      focusNode: focusNode,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _suffix(context, c),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget? _suffix(BuildContext context, TextEditingController? c) {
    final scan = onScan == null
        ? null
        : IconButton(
            key: const Key('search-scan'),
            tooltip: scanTooltip,
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: onScan,
          );
    if (c == null) return scan;
    final clear = ListenableBuilder(
      listenable: c,
      builder: (context, _) => c.text.isEmpty
          ? const SizedBox.shrink()
          : IconButton(
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              icon: const Icon(Icons.close),
              onPressed: () {
                c.clear();
                onChanged('');
              },
            ),
    );
    if (scan == null) return clear;
    return Row(mainAxisSize: MainAxisSize.min, children: [clear, scan]);
  }
}
