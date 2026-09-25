import 'dart:convert';

import 'package:flutter/material.dart';

import 'builder_controller.dart';
import 'schema.dart';
import 'tree_panel.dart';

/// Right pane: form for the selected node plus node actions.
class PropertyPanel extends StatelessWidget {
  const PropertyPanel({required this.controller, super.key});

  final BuilderController controller;

  @override
  Widget build(BuildContext context) {
    final node = controller.selectedNode;
    final spec = controller.specOf(node);
    final path = controller.selected;

    if (node == null) {
      return Center(
        child: Text(
          controller.isEmpty ? 'Drop a widget onto the canvas to start' : 'Select a node in the outline',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    final pathKey = path.join('/');
    final isListItem = path.isNotEmpty && path.last is int;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Icon(iconFor(node['type']?.toString())),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                node['type']?.toString() ?? '?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (spec == null)
              Tooltip(
                message: 'Unknown type: renders as empty SizedBox',
                child: Icon(Icons.warning_amber, color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          path.isEmpty ? 'root' : path.join(' › '),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            TypePickerButton(
              onlyContainers: true,
              onPick: controller.wrapSelected,
              child: const _Chip(icon: Icons.add_box_outlined, label: 'Wrap with'),
            ),
            if (isListItem) ...[
              _ActionChip(
                icon: Icons.arrow_upward,
                label: 'Up',
                onTap: () => controller.moveSelected(-1),
              ),
              _ActionChip(
                icon: Icons.arrow_downward,
                label: 'Down',
                onTap: () => controller.moveSelected(1),
              ),
              _ActionChip(
                icon: Icons.copy,
                label: 'Duplicate',
                onTap: controller.duplicateSelected,
              ),
            ],
            _ActionChip(
              icon: Icons.delete_outline,
              label: path.isEmpty ? 'Reset' : 'Delete',
              onTap: controller.deleteSelected,
              destructive: true,
            ),
          ],
        ),
        const Divider(height: 24),
        if (spec != null)
          for (final field in spec.fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FieldEditor(
                key: ValueKey('$pathKey#${field.key}'),
                field: field,
                value: _read(node, field.path),
                onEditStart: controller.snapshot,
                onChanged: (v) => controller.setField(field.path, v),
                onLiveChange: (v) => controller.setField(field.path, v, recordUndo: false),
              ),
            ),
        const Divider(height: 24),
        ExpansionTile(
          title: const Text('Raw JSON (this node)'),
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 8),
          children: [
            _RawJsonEditor(
              key: ValueKey('$pathKey#raw#${jsonEncode(node).hashCode}'),
              json: node,
              onApply: controller.replaceSelected,
            ),
          ],
        ),
      ],
    );
  }

  static Object? _read(Map<String, dynamic> node, List<String> keys) {
    dynamic cursor = node;
    for (final key in keys) {
      if (cursor is! Map) return null;
      cursor = cursor[key];
    }
    return cursor;
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 16),
    label: Text(label),
    visualDensity: VisualDensity.compact,
  );
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;

    return ActionChip(
      avatar: Icon(icon, size: 16, color: destructive ? error : null),
      label: Text(label, style: destructive ? TextStyle(color: error) : null),
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
    );
  }
}

/// One form control, chosen by [FieldKind]. Text-like inputs update the
/// preview on every keystroke via [onLiveChange]; [onEditStart] fires once
/// when the field gains focus so the whole edit is a single undo step.
class _FieldEditor extends StatefulWidget {
  const _FieldEditor({
    required this.field,
    required this.value,
    required this.onChanged,
    required this.onLiveChange,
    required this.onEditStart,
    super.key,
  });

  final FieldSpec field;
  final Object? value;
  final ValueChanged<Object?> onChanged;
  final ValueChanged<Object?> onLiveChange;
  final VoidCallback onEditStart;

  @override
  State<_FieldEditor> createState() => _FieldEditorState();
}

class _FieldEditorState extends State<_FieldEditor> {
  late final TextEditingController _text = TextEditingController(
    text: widget.value?.toString() ?? '',
  );
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (_focus.hasFocus) widget.onEditStart();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _text.dispose();
    super.dispose();
  }

  Object? _parse(String raw) {
    if (raw.isEmpty) return null;

    return switch (widget.field.kind) {
      FieldKind.number => num.tryParse(raw) ?? raw,
      FieldKind.integer => int.tryParse(raw) ?? raw,
      // Plain numbers stay numeric; "a,b" style stays a string.
      FieldKind.edgeInsets => num.tryParse(raw) ?? raw,
      _ => raw,
    };
  }

  void _live() {
    final raw = _text.text.trim();
    if (raw == (widget.value?.toString() ?? '')) return;
    widget.onLiveChange(_parse(raw));
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;

    switch (field.kind) {
      case FieldKind.choice:
        return _dropdown(field.options);
      case FieldKind.color:
        return _dropdown(colorNames, swatch: true);
      case FieldKind.opacity:
        final v = (widget.value is num) ? (widget.value as num).toDouble() : 1.0;
        return Row(
          children: [
            SizedBox(width: 110, child: Text(field.title, style: _labelStyle(context))),
            Expanded(
              child: Slider(
                value: v.clamp(0, 1),
                divisions: 20,
                label: v.toStringAsFixed(2),
                onChanged: (nv) => widget.onChanged(nv == 1 ? null : double.parse(nv.toStringAsFixed(2))),
              ),
            ),
            SizedBox(width: 36, child: Text(v.toStringAsFixed(2), style: _labelStyle(context))),
          ],
        );
      default:
        return TextField(
          controller: _text,
          focusNode: _focus,
          onChanged: (_) => _live(),
          keyboardType: switch (field.kind) {
            FieldKind.number || FieldKind.integer => const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            _ => TextInputType.text,
          },
          decoration: InputDecoration(
            labelText: field.title,
            hintText: field.hint,
            isDense: true,
            border: const OutlineInputBorder(),
            suffixIcon: _text.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () {
                      _text.clear();
                      widget.onChanged(null);
                      setState(() {});
                    },
                  ),
          ),
        );
    }
  }

  Widget _dropdown(List<String> options, {bool swatch = false}) {
    final current = widget.value?.toString();
    final scheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<String?>(
      initialValue: options.contains(current) ? current : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: widget.field.title,
        helperText: widget.field.hint,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text('— default —', style: TextStyle(color: scheme.onSurfaceVariant)),
        ),
        for (final option in options)
          DropdownMenuItem<String?>(
            value: option,
            child: Row(
              children: [
                if (swatch) ...[
                  _Swatch(name: option),
                  const SizedBox(width: 8),
                ],
                Flexible(child: Text(option, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
      ],
      onChanged: widget.onChanged,
    );
  }

  TextStyle? _labelStyle(BuildContext context) => Theme.of(context).textTheme.bodySmall;
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    // Resolve through the package's own palette so swatches match the preview.
    final color = _paletteColor(context, name);

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    );
  }
}

Color? _paletteColor(BuildContext context, String name) =>
    PaletteResolver.of(context)?.call(name);

/// Lets the page inject the package palette without importing it here.
class PaletteResolver extends InheritedWidget {
  const PaletteResolver({required this.resolve, required super.child, super.key});

  final Color? Function(String name) resolve;

  static Color? Function(String)? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PaletteResolver>()?.resolve;

  @override
  bool updateShouldNotify(PaletteResolver oldWidget) => resolve != oldWidget.resolve;
}

class _RawJsonEditor extends StatefulWidget {
  const _RawJsonEditor({required this.json, required this.onApply, super.key});

  final Map<String, dynamic> json;
  final ValueChanged<Map<String, dynamic>> onApply;

  @override
  State<_RawJsonEditor> createState() => _RawJsonEditorState();
}

class _RawJsonEditorState extends State<_RawJsonEditor> {
  late final _controller = TextEditingController(
    text: const JsonEncoder.withIndent('  ').convert(widget.json),
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    try {
      final parsed = jsonDecode(_controller.text);
      if (parsed is! Map<String, dynamic>) throw const FormatException('Expected an object');
      setState(() => _error = null);
      widget.onApply(parsed);
    } on FormatException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          maxLines: 14,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            errorText: _error,
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(onPressed: _apply, child: const Text('Apply JSON')),
      ],
    );
  }
}
