import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_input.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Fast expiry entry: `MM / YYYY` on a numeric keypad with auto-advance, or
/// `DD / MM / YYYY` after switching on "Exact date". Shows the resolved date
/// ("Expires 31 Aug 2027") and non-blocking warnings.
///
/// Reports the parsed [ExpiryDate] through [onChanged], or null while the
/// input is incomplete or invalid.
class ExpiryInput extends StatefulWidget {
  const ExpiryInput({
    required this.today,
    required this.onChanged,
    this.initial,
    this.errorText,
    super.key,
  });

  final DateTime today;
  final ExpiryDate? initial;
  final ValueChanged<ExpiryDate?> onChanged;

  /// Error from the parent form (e.g. "required"); live parse errors are shown
  /// by the widget itself.
  final String? errorText;

  @override
  State<ExpiryInput> createState() => _ExpiryInputState();
}

class _ExpiryInputState extends State<ExpiryInput> {
  final _day = TextEditingController();
  final _month = TextEditingController();
  final _year = TextEditingController();
  final _dayFocus = FocusNode();
  final _monthFocus = FocusNode();
  final _yearFocus = FocusNode();
  bool _exact = false;
  ExpiryParse _parse = const ExpiryIncomplete();

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _exact = i.precision == ExpiryPrecision.day;
      _day.text = i.date.day.toString().padLeft(2, '0');
      _month.text = i.date.month.toString().padLeft(2, '0');
      _year.text = i.date.year.toString();
      _parse = ExpiryParsed(i);
    }
  }

  @override
  void dispose() {
    for (final c in [_day, _month, _year]) {
      c.dispose();
    }
    for (final f in [_dayFocus, _monthFocus, _yearFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  void _recompute() {
    final result = parseExpiryInput(
      day: _day.text,
      month: _month.text,
      year: _year.text,
      exact: _exact,
    );
    setState(() => _parse = result);
    widget.onChanged(result is ExpiryParsed ? result.value : null);
  }

  /// A value is complete once it has two digits, or one digit that cannot
  /// start a valid two-digit number (months 2-9, days 4-9).
  bool _complete(String text, int firstDigitLimit) {
    if (text.length >= 2) return true;
    if (text.length == 1) return int.parse(text) >= firstDigitLimit;
    return false;
  }

  void _toggleExact(bool value) {
    setState(() => _exact = value);
    _recompute();
    if (value && _day.text.isEmpty) _dayFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final parse = _parse;
    var error = widget.errorText;
    String? info;
    String? warning;
    if (parse is ExpiryInvalid) {
      error = l10n.errExpiryInvalid;
    } else if (parse is ExpiryParsed) {
      error = null;
      info = l10n.expiresOn(formatDate(context, parse.value.date));
      warning = switch (expiryWarning(parse.value, widget.today)) {
        ExpiryWarning.inPast => l10n.expiryWarnPast,
        ExpiryWarning.farFuture => l10n.expiryWarnFar,
        null => null,
      };
    }

    Widget field({
      required Key key,
      required TextEditingController controller,
      required FocusNode focus,
      required String label,
      required int maxLength,
      required double width,
      ValueChanged<String>? onChanged,
      bool autofocus = false,
    }) {
      return SizedBox(
        width: width,
        child: TextField(
          key: key,
          controller: controller,
          focusNode: focus,
          autofocus: autofocus,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(maxLength),
          ],
          decoration: InputDecoration(
            labelText: label,
            counterText: '',
            border: const OutlineInputBorder(),
            errorText: error != null ? '' : null,
            errorStyle: const TextStyle(height: 0, fontSize: 0),
          ),
          onChanged: (v) {
            onChanged?.call(v);
            _recompute();
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.expiryLabel, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_exact) ...[
              field(
                key: const Key('expiry-day'),
                controller: _day,
                focus: _dayFocus,
                label: l10n.expiryDay,
                maxLength: 2,
                width: 64,
                onChanged: (v) {
                  if (_complete(v, 4)) _monthFocus.requestFocus();
                },
              ),
              const _Slash(),
            ],
            field(
              key: const Key('expiry-month'),
              controller: _month,
              focus: _monthFocus,
              label: l10n.expiryMonth,
              maxLength: 2,
              width: 64,
              onChanged: (v) {
                if (_complete(v, 2)) _yearFocus.requestFocus();
              },
            ),
            const _Slash(),
            field(
              key: const Key('expiry-year'),
              controller: _year,
              focus: _yearFocus,
              label: l10n.expiryYear,
              maxLength: 4,
              width: 88,
            ),
            const Spacer(),
            Column(
              children: [
                Text(l10n.expiryExactToggle, style: theme.textTheme.labelSmall),
                Switch(
                  key: const Key('expiry-exact-toggle'),
                  value: _exact,
                  onChanged: _toggleExact,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (error != null)
          Text(
            error,
            key: const Key('expiry-error'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          )
        else if (info != null)
          Text(
            info,
            key: const Key('expiry-resolved'),
            style: theme.textTheme.bodyMedium,
          ),
        if (warning != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              key: const Key('expiry-warning'),
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    warning,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Slash extends StatelessWidget {
  const _Slash();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 14, left: 6, right: 6),
    child: Text('/', style: TextStyle(fontSize: 20)),
  );
}
