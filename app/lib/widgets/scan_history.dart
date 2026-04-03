import 'package:flutter/material.dart';
import '../models/scan_entry.dart';

class ScanHistorySheet extends StatelessWidget {
  final List<ScanEntry> entries;
  final void Function(ScanEntry entry) onSend;

  const ScanHistorySheet({
    super.key,
    required this.entries,
    required this.onSend,
  });

  static void show(
    BuildContext context, {
    required List<ScanEntry> entries,
    required void Function(ScanEntry entry) onSend,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ScanHistorySheet(entries: entries, onSend: onSend),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('Scan History', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    '${entries.length} scans',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        'No scans yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        // Show newest first
                        final entry = entries[entries.length - 1 - index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            entry.sent ? Icons.check_circle : Icons.circle_outlined,
                            color: entry.sent
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          title: Text(
                            entry.barcode,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(entry.formattedTime),
                          trailing: IconButton(
                            icon: const Icon(Icons.send, size: 20),
                            tooltip: 'Send',
                            onPressed: () => onSend(entry),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
