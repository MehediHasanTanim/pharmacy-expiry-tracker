import 'package:pharmacy_expiry_tracker/domain/entities/reorder.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier_return.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// The message sent to a supplier with goods that go back (SUP-10).
String buildReturnText(
  AppLocalizations l10n, {
  required String supplierName,
  required String date,
  required ReturnView view,
  required String Function(int minor) money,
}) {
  final b = StringBuffer()..writeln(l10n.returnHeaderText(supplierName, date));
  for (final l in view.lines) {
    b.writeln(
      '• ${l10n.returnLineText(l.quantity, l.medicineName, l.batchNumber)}',
    );
  }
  if (view.note != null) b.writeln(view.note);
  if (view.credit != null) {
    b.writeln(l10n.returnCreditText(money(view.credit!.minor)));
  }
  return b.toString().trimRight();
}

/// An order list for one supplier, formatted for WhatsApp (bold with `*`) and
/// readable anywhere else (ROR-6).
String buildOrderText(
  AppLocalizations l10n, {
  required String supplierName,
  required List<({String name, int quantity})> lines,
}) {
  final b = StringBuffer()..writeln(l10n.orderShareHeader(supplierName));
  for (final l in lines) {
    b.writeln(l10n.orderShareLine(l.name, l.quantity));
  }
  b
    ..writeln()
    ..write(l10n.orderShareGreeting);
  return b.toString();
}

/// Items of an order list: the open order's quantity when there is one, else
/// the suggested quantity.
int orderQuantityFor(ReorderItem item, int? edited) =>
    edited ?? item.order?.quantity ?? item.suggested;
