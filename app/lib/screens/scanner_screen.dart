import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/scan_entry.dart';
import '../services/scanner_service.dart';
import '../services/webhook_service.dart';
import '../widgets/ad_banner.dart';
import '../widgets/scan_history.dart';
import 'settings_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final ScannerService _scannerService;
  final List<ScanEntry> _history = [];

  bool _autoSend = true;
  bool _flashVisible = false;
  String? _serverUrl;
  bool _permissionGranted = false;
  bool _permissionDeniedForever = false;

  @override
  void initState() {
    super.initState();
    _scannerService = ScannerService(onBarcodeDetected: _onBarcode);
    _requestCamera();
    _loadPrefs();
  }

  Future<void> _requestCamera() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() {
      _permissionGranted = status.isGranted;
      _permissionDeniedForever = status.isPermanentlyDenied;
    });
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _autoSend = prefs.getBool('auto_send') ?? true;
      _serverUrl = prefs.getString('server_url');
    });
  }

  void _onBarcode(String barcode) {
    HapticFeedback.mediumImpact();
    _triggerFlash();

    final entry = ScanEntry(timestamp: DateTime.now(), barcode: barcode);
    setState(() {
      _history.add(entry);
      if (_history.length > 10) _history.removeAt(0);
    });

    if (_autoSend) {
      _sendScan(entry);
    } else {
      _showManualSendSheet(entry);
    }
  }

  void _triggerFlash() {
    setState(() => _flashVisible = true);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _flashVisible = false);
    });
  }

  Future<void> _sendScan(ScanEntry entry) async {
    final url = _serverUrl;
    if (url == null || url.isEmpty) {
      _showSnackBar('Set a server URL in settings', isError: true);
      return;
    }

    final (success, message) = await WebhookService.sendScan(url, entry.barcode);
    if (!mounted) return;

    if (success) {
      setState(() => entry.sent = true);
    }
    _showSnackBar(message, isError: !success);
  }

  void _showManualSendSheet(ScanEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Scanned', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SelectableText(
                entry.barcode,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Dismiss'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _sendScan(entry);
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Send'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleAutoSend(bool value) async {
    setState(() => _autoSend = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_send', value);
  }

  void _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    _loadPrefs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUrl = _serverUrl != null && _serverUrl!.isNotEmpty;

    return Scaffold(
      body: Column(
        children: [
          // Server URL warning banner
          if (!hasUrl)
            MaterialBanner(
              content: const Text('Set a server URL to start sending scans.'),
              leading: const Icon(Icons.warning_amber_rounded),
              actions: [
                TextButton(
                  onPressed: _openSettings,
                  child: const Text('Settings'),
                ),
              ],
            ),

          // Camera + overlay (or permission prompt)
          Expanded(
            child: _permissionGranted
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        onDetect: _scannerService.handleDetection,
                      ),
                      _ScanOverlay(color: theme.colorScheme.primary),
                      if (_flashVisible)
                        const ColoredBox(color: Colors.white54),
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _permissionDeniedForever
                                ? 'Camera permission was permanently denied.\nPlease enable it in your device settings.'
                                : 'Camera permission is required to scan barcodes.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: _permissionDeniedForever
                                ? openAppSettings
                                : _requestCamera,
                            icon: Icon(_permissionDeniedForever
                                ? Icons.settings
                                : Icons.camera_alt),
                            label: Text(_permissionDeniedForever
                                ? 'Open settings'
                                : 'Grant permission'),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Bottom controls
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  const Icon(Icons.bolt, size: 18),
                  const SizedBox(width: 4),
                  const Text('Auto-send'),
                  Switch(
                    value: _autoSend,
                    onChanged: _toggleAutoSend,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.history),
                    tooltip: 'Scan history',
                    onPressed: () => ScanHistorySheet.show(
                      context,
                      entries: _history,
                      onSend: _sendScan,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Settings',
                    onPressed: _openSettings,
                  ),
                ],
              ),
            ),
          ),

          // Ad banner pinned at very bottom
          const AdBannerWidget(),
        ],
      ),
    );
  }
}

/// Draws a rounded-rectangle scan-area indicator in the center of the camera.
class _ScanOverlay extends StatelessWidget {
  final Color color;
  const _ScanOverlay({required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.maxWidth * 0.7;
      final left = (constraints.maxWidth - size) / 2;
      final top = (constraints.maxHeight - size) / 2;
      final cutout = Rect.fromLTWH(left, top, size, size);

      return Stack(
        children: [
          // Dimmed background with transparent cutout
          ClipPath(
            clipper: _CutoutClipper(cutout: cutout, radius: 16),
            child: const SizedBox.expand(
              child: ColoredBox(color: Colors.black45),
            ),
          ),
          // Border around the scan area
          Positioned(
            left: left,
            top: top,
            width: size,
            height: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: color.withValues(alpha: 0.7), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _CutoutClipper extends CustomClipper<Path> {
  final Rect cutout;
  final double radius;
  _CutoutClipper({required this.cutout, required this.radius});

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cutout, Radius.circular(radius)))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(covariant _CutoutClipper oldClipper) =>
      cutout != oldClipper.cutout;
}
