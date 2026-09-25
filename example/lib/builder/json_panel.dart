import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'builder_controller.dart';
import 'console.dart';

/// Right sidebar tab: the live JSON document, read-only, with copy.
class JsonPanel extends StatelessWidget {
  const JsonPanel({required this.controller, required this.onImport, super.key});

  final BuilderController controller;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final json = controller.prettyJson;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
          child: Row(
            children: [
              Text(
                '${json.split('\n').length} lines',
                style: TextStyle(fontSize: 11, color: scheme.outline),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.file_upload_outlined, size: 16),
                label: const Text('Import'),
              ),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: json));
                  ConsoleLog.instance.info('JSON copied to clipboard');
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: SelectableText(
              json,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
