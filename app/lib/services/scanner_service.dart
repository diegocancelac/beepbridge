import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerService {
  final void Function(String barcode) onBarcodeDetected;
  final Duration debounceDuration;

  DateTime _lastScanTime = DateTime(0);
  String? _lastScanValue;

  ScannerService({
    required this.onBarcodeDetected,
    this.debounceDuration = const Duration(milliseconds: 1500),
  });

  void handleDetection(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode.isEmpty) return;

    final now = DateTime.now();
    if (barcode == _lastScanValue &&
        now.difference(_lastScanTime) < debounceDuration) {
      return;
    }

    _lastScanTime = now;
    _lastScanValue = barcode;
    onBarcodeDetected(barcode);
  }
}
