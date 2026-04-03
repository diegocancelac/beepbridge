class ScanEntry {
  final DateTime timestamp;
  final String barcode;
  bool sent;

  ScanEntry({
    required this.timestamp,
    required this.barcode,
    this.sent = false,
  });

  String get formattedTime =>
      '${timestamp.hour.toString().padLeft(2, '0')}:'
      '${timestamp.minute.toString().padLeft(2, '0')}:'
      '${timestamp.second.toString().padLeft(2, '0')}';
}
