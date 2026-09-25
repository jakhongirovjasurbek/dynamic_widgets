import 'package:flutter/material.dart';

import 'builder_controller.dart';
import 'schema.dart';

const _icons = <String, IconData>{
  'container': Icons.crop_square,
  'row': Icons.view_column_outlined,
  'column': Icons.view_agenda_outlined,
  'stack': Icons.layers_outlined,
  'sizedBox': Icons.aspect_ratio,
  'padding': Icons.padding,
  'center': Icons.center_focus_strong_outlined,
  'align': Icons.align_horizontal_left,
  'positioned': Icons.open_with,
  'icon': Icons.image_outlined,
  'text': Icons.text_fields,
  'expanded': Icons.unfold_more,
  'singleChildScrollView': Icons.swap_vert,
  'backDropFilter': Icons.blur_on,
  'clipRRect': Icons.rounded_corner,
};

IconData iconFor(String? type) => _icons[type] ?? Icons.help_outline;

/// Outline of the document. Rows are drag sources (move) and drop targets
/// (palette types or other nodes). Dropping on a container adds a child;
/// dropping on a leaf inserts before it.
class TreePanel extends StatelessWidget {
  const TreePanel({required this.controller, super.key});

  final BuilderController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isEmpty) return _EmptyDropZone(controller: controller);

    final rows = <Widget>[];
    _collect(context, const [], controller.root, 0, rows);

    return ListView(padding: const EdgeInsets.symmetric(vertical: 4), children: rows);
  }

  void _collect(
    BuildContext context,
    NodePath path,
    Map<String, dynamic> node,
    int depth,
    List<Widget> out,
  ) {
    final type = node['type']?.toString();
    final spec = widgetSpecs[type];
    final selected = _samePath(path, controller.selected);
    final label = switch (type) {
      'text' => '"${(node['title'] ?? node['value'] ?? node['data'] ?? '').toString()}"',
      'icon' => node['source']?.toString() ?? '',
      _ => '',
    };

    out.add(
      _TreeRow(
        path: path,
        depth: depth,
        icon: iconFor(type),
        type: type ?? '?',
        detail: label,
        selected: selected,
        unknown: spec == null,
        isContainer: spec != null && spec.children != ChildKind.none,
        onTap: () => controller.select(path),
        onDrop: (payload) => controller.dropOn(path, payload),
        canDrop: (payload) => _canDrop(path, spec, payload),
      ),
    );

    for (final (childPath, child) in controller.childrenOf(path, node)) {
      _collect(context, childPath, child, depth + 1, out);
    }

    if (spec != null && spec.children != ChildKind.none) {
      final hasSingle = spec.children == ChildKind.single && node['child'] is Map;
      if (!hasSingle) {
        out.add(_AddRow(depth: depth + 1, onPick: (t) => controller.addChild(path, t)));
      }
    }
  }

  bool _canDrop(NodePath target, WidgetSpec? spec, Object payload) {
    if (spec == null) return false;
    if (payload is NodeDrag) {
      // No dropping onto itself or into its own subtree.
      if (target.length >= payload.path.length &&
          _samePath(target.sublist(0, payload.path.length), payload.path)) {
        return false;
      }
    }
    if (spec.children == ChildKind.none) return target.isNotEmpty && target.last is int;
    return true;
  }

  static bool _samePath(NodePath a, NodePath b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _TreeRow extends StatelessWidget {
  const _TreeRow({
    required this.path,
    required this.depth,
    required this.icon,
    required this.type,
    required this.detail,
    required this.selected,
    required this.unknown,
    required this.isContainer,
    required this.onTap,
    required this.onDrop,
    required this.canDrop,
  });

  final NodePath path;
  final int depth;
  final IconData icon;
  final String type;
  final String detail;
  final bool selected;
  final bool unknown;
  final bool isContainer;
  final VoidCallback onTap;
  final ValueChanged<Object> onDrop;
  final bool Function(Object payload) canDrop;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DragTarget<Object>(
      onWillAcceptWithDetails: (d) => canDrop(d.data),
      onAcceptWithDetails: (d) => onDrop(d.data),
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;

        final row = InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: selected ? scheme.primaryContainer : null,
              border: hovering
                  ? Border(
                      // Container: highlight whole row. Leaf: insertion line above.
                      top: BorderSide(color: scheme.primary, width: isContainer ? 0 : 2),
                      left: BorderSide(color: scheme.primary, width: isContainer ? 3 : 0),
                    )
                  : null,
            ),
            padding: EdgeInsets.only(left: 8.0 + depth * 16, right: 8, top: 5, bottom: 5),
            child: Row(
              children: [
                Icon(icon, size: 16, color: unknown ? scheme.error : scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: unknown ? scheme.error : scheme.onSurface,
                  ),
                ),
                if (detail.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );

        if (path.isEmpty) return row; // root is not draggable

        return Draggable<Object>(
          data: NodeDrag(path),
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: scheme.onPrimaryContainer),
                  const SizedBox(width: 6),
                  Text(type, style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 12)),
                ],
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.35, child: row),
          child: row,
        );
      },
    );
  }
}

/// Shown when the document has no root yet: accepts a palette drop.
class _EmptyDropZone extends StatelessWidget {
  const _EmptyDropZone({required this.controller});

  final BuilderController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DragTarget<Object>(
      onWillAcceptWithDetails: (d) => d.data is PaletteDrag,
      onAcceptWithDetails: (d) => controller.dropOn(const [], d.data),
      builder: (context, candidates, _) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: candidates.isNotEmpty ? scheme.primary : scheme.outlineVariant,
            width: candidates.isNotEmpty ? 2 : 1,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline, color: scheme.outline),
                const SizedBox(height: 8),
                Text(
                  'No widget yet.\nDrop one here to make it the root.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddRow extends StatelessWidget {
  const _AddRow({required this.depth, required this.onPick});

  final int depth;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.0 + depth * 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TypePickerButton(
          onPick: onPick,
          child: Text(
            '+ add child',
            style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.outline),
          ),
        ),
      ),
    );
  }
}

/// A popup listing every `JsonWidgetTypes` value.
class TypePickerButton extends StatelessWidget {
  const TypePickerButton({
    required this.onPick,
    required this.child,
    this.onlyContainers = false,
    super.key,
  });

  final ValueChanged<String> onPick;
  final Widget child;

  /// Show only types that can hold a child (for "wrap with").
  final bool onlyContainers;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: '',
      onSelected: onPick,
      itemBuilder: (context) => [
        for (final spec in widgetSpecs.values)
          if (!onlyContainers || spec.children != ChildKind.none)
            PopupMenuItem(
              value: spec.type,
              height: 36,
              child: Row(
                children: [
                  Icon(iconFor(spec.type), size: 18),
                  const SizedBox(width: 10),
                  Text(spec.type),
                ],
              ),
            ),
      ],
      child: Padding(padding: const EdgeInsets.all(4), child: child),
    );
  }
}
