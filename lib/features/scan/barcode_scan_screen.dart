import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Opens the camera scanner and returns the scanned value (null if the user
/// backs out). Replaced in tests, which have no camera.
typedef BarcodeScan = Future<String?> Function(BuildContext context);

final barcodeScanProvider = Provider<BarcodeScan>(
  (ref) =>
      (context) => Navigator.of(context, rootNavigator: true).push<String>(
        MaterialPageRoute(builder: (_) => const BarcodeScanScreen()),
      ),
);

/// Full-screen camera view that returns the first barcode it reads (SCN-2).
/// A torch switch helps in a dim stockroom; typing the number is always
/// available when the camera is off, denied or the label is damaged.
class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  // Not "no duplicates": a screen that returns on the first read does not need
  // it, and the guard below stops a second pop from a burst of reads.
  final _controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.dataMatrix,
      BarcodeFormat.qrCode,
    ],
  );
  bool _done = false;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  void _finish(String value) {
    if (_done) return;
    _done = true;
    Navigator.of(context).pop(value);
  }

  void _onDetect(BarcodeCapture capture) {
    for (final b in capture.barcodes) {
      final v = b.rawValue;
      if (v != null && v.trim().isNotEmpty) {
        _finish(v);
        return;
      }
    }
  }

  Future<void> _type() async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => const _TypeDialog(),
    );
    if (value != null && value.trim().isNotEmpty) _finish(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanTitle),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, _) => IconButton(
              key: const Key('scan-torch'),
              tooltip: l10n.scanTorch,
              icon: Icon(
                state.torchState == TorchState.on
                    ? Icons.flash_on
                    : Icons.flash_off,
              ),
              onPressed: state.isRunning ? _controller.toggleTorch : null,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) => _ScanError(
                message:
                    error.errorCode == MobileScannerErrorCode.permissionDenied
                    ? l10n.scanPermissionDenied
                    : l10n.scanUnsupported,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(l10n.scanHint, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('scan-type'),
                  onPressed: _type,
                  icon: const Icon(Icons.keyboard_outlined),
                  label: Text(l10n.scanTypeInstead),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanError extends StatelessWidget {
  const _ScanError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}

class _TypeDialog extends StatefulWidget {
  const _TypeDialog();

  @override
  State<_TypeDialog> createState() => _TypeDialogState();
}

class _TypeDialogState extends State<_TypeDialog> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.scanTypeTitle),
      content: TextField(
        key: const Key('scan-type-field'),
        controller: _c,
        autofocus: true,
        keyboardType: TextInputType.visiblePassword,
        decoration: InputDecoration(labelText: l10n.scanTypeTitle),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const Key('scan-type-ok'),
          onPressed: () => Navigator.pop(context, _c.text),
          child: Text(l10n.actionConfirm),
        ),
      ],
    );
  }
}
