import 'package:flutter/material.dart';

import 'builder_controller.dart';
import 'schema.dart';
import 'tree_panel.dart';

/// Left sidebar section: every widget type as a draggable tile.
/// Drag onto the outline or the canvas; double-click to add to the selection.
class PalettePanel extends StatelessWidget {
  const PalettePanel({required this.controller, super.key});

  final BuilderController controller;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<WidgetSpec>>{
      'Layout': [
        for (final t in ['container', 'row', 'column', 'stack', 'sizedBox', 'padding'])
          widgetSpecs[t]!,
      ],
      'Position': [
        for (final t in ['center', 'align', 'positioned', 'expanded']) widgetSpecs[t]!,
      ],
      'Content': [for (final t in ['text', 'icon']) widgetSpecs[t]!],
      'Effects': [
        for (final t in ['singleChildScrollView', 'backDropFilter', 'clipRRect']) widgetSpecs[t]!,
      ],
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            child: Text(
              entry.key.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                letterSpacing: 1,
              ),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final spec in entry.value)
                _PaletteTile(spec: spec, onDoubleTap: () => _quickAdd(spec.type)),
            ],
          ),
        ],
      ],
    );
  }

  /// Adds to the selected node when it can hold children, else to the root.
  void _quickAdd(String type) {
    if (controller.isEmpty) {
      controller.addChild(const [], type);
    } else if (controller.canAccept(controller.selected)) {
      controller.addChild(controller.selected, type);
    } else if (controller.canAccept(const [])) {
      controller.addChild(const [], type);
    } else {
      controller.dropOn(controller.selected, PaletteDrag(type));
    }
  }
}

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({required this.spec, required this.onDoubleTap});

  final WidgetSpec spec;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final tile = Container(
      width: 112,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(iconFor(spec.type), size: 16, color: scheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              spec.type,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );

    return Draggable<Object>(
      data: PaletteDrag(spec.type),
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.9, child: tile),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: tile),
      child: Tooltip(
        message: 'Drag to the outline or canvas · double-click to add',
        waitDuration: const Duration(milliseconds: 600),
        child: GestureDetector(
          onDoubleTap: onDoubleTap,
          child: MouseRegion(cursor: SystemMouseCursors.grab, child: tile),
        ),
      ),
    );
  }
}
