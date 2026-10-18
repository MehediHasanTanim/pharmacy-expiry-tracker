import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

String dosageFormLabel(AppLocalizations l, DosageForm f) => switch (f) {
  DosageForm.tablet => l.formDosageTablet,
  DosageForm.capsule => l.formDosageCapsule,
  DosageForm.syrup => l.formDosageSyrup,
  DosageForm.injection => l.formDosageInjection,
  DosageForm.ointment => l.formDosageOintment,
  DosageForm.drops => l.formDosageDrops,
  DosageForm.other => l.formDosageOther,
};

String unitLabel(AppLocalizations l, StockUnit u) => switch (u) {
  StockUnit.strip => l.unitStrip,
  StockUnit.box => l.unitBox,
  StockUnit.bottle => l.unitBottle,
  StockUnit.vial => l.unitVial,
  StockUnit.piece => l.unitPiece,
};

String batchStatusLabel(AppLocalizations l, BatchStatus s) => switch (s) {
  BatchStatus.active => l.statusActive,
  BatchStatus.depleted => l.statusDepleted,
  BatchStatus.returned => l.statusReturned,
  BatchStatus.discarded => l.statusDiscarded,
};

String reasonLabel(AppLocalizations l, AdjustmentReason r) => switch (r) {
  AdjustmentReason.received => l.adjustReasonReceived,
  AdjustmentReason.sold => l.adjustReasonSold,
  AdjustmentReason.damaged => l.adjustReasonDamaged,
  AdjustmentReason.discardedExpired => l.adjustReasonExpired,
  AdjustmentReason.returned => l.adjustReasonReturned,
  AdjustmentReason.correction => l.adjustReasonCorrection,
  AdjustmentReason.other => l.adjustReasonOther,
};

String formatDate(BuildContext context, DateTime d) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(d);

String formatDateTime(BuildContext context, DateTime d) {
  final locale = Localizations.localeOf(context).toString();
  return '${DateFormat.yMMMd(locale).format(d)} ${DateFormat.jm(locale).format(d)}';
}

String invoiceStatusLabel(AppLocalizations l, InvoiceStatus s) => switch (s) {
  InvoiceStatus.unpaid => l.statusUnpaid,
  InvoiceStatus.partial => l.statusPartial,
  InvoiceStatus.paid => l.statusPaid,
  InvoiceStatus.overdue => l.statusOverdue,
};

String paymentMethodLabel(AppLocalizations l, PaymentMethod m) => switch (m) {
  PaymentMethod.cash => l.paymentMethodCash,
  PaymentMethod.bank => l.paymentMethodBank,
  PaymentMethod.mobile => l.paymentMethodMobile,
  PaymentMethod.cheque => l.paymentMethodCheque,
  PaymentMethod.other => l.paymentMethodOther,
};
