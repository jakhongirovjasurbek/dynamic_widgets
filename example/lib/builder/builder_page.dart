import 'dart:convert';

import 'package:dynamic_widgets/dynamic_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'builder_controller.dart';
import 'console.dart';
import 'json_panel.dart';
import 'palette_panel.dart';
import 'property_panel.dart';
import 'schema.dart';
import 'tree_panel.dart';

/// Desktop-style editor for `dynamic_widgets` JSON.
///
/// ```
/// ┌ menu bar ──────────────────────────────────────────────┐
/// │ palette  │            canvas (live render)  │ outline / │
/// │          │                                  │ inspector │
/// │          │                                  │ / json    │
/// ├ console ───────────────────────────────────────────────┤
/// ```
class BuilderPage extends StatefulWidget {
  const BuilderPage({super.key});

  @override
  State<BuilderPage> createState() => _BuilderPageState();
}

class _BuilderPageState extends State<BuilderPage> {
  final _controller = BuilderController();
  bool _darkPreview = false;
  double _previewWidth = 360;
  bool _showConsole = true;
  double _consoleHeight = 200;
  double _leftWidth = 260;
  double _rightWidth = 340;
  int _rightTab = 0; // 0 = outline, 1 = inspector, 2 = json

  @override
  void initState() {
    super.initState();
    ConsoleLog.instance.info('ready — drag widgets from the palette onto the outline or canvas');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): _controller.undo,
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true): _controller.redo,
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): _controller.undo,
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): _controller.redo,
        const SingleActivator(LogicalKeyboardKey.keyD, meta: true): _controller.duplicateSelected,
        const SingleActivator(LogicalKeyboardKey.keyD, control: true): _controller.duplicateSelected,
        const SingleActivator(LogicalKeyboardKey.backspace, meta: true): _controller.deleteSelected,
        const SingleActivator(LogicalKeyboardKey.delete, control: true): _controller.deleteSelected,
        const SingleActivator(LogicalKeyboardKey.keyE, meta: true, shift: true): _export,
        const SingleActivator(LogicalKeyboardKey.keyI, meta: true, shift: true): _import,
      },
      child: Focus(
        autofocus: true,
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Scaffold(
            body: Column(
              children: [
                _menuBar(context),
                const Divider(height: 1),
                Expanded(child: _workspace(context)),
                if (_showConsole) ...[
                  _HorizontalHandle(
                    onDrag: (dy) => setState(
                      () => _consoleHeight = (_consoleHeight - dy).clamp(80.0, 600.0),
                    ),
                  ),
                  SizedBox(height: _consoleHeight, child: const ConsolePanel()),
                ],
                _statusBar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------- menu bar

  Widget _menuBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.surfaceContainerHigh,
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(Icons.widgets_outlined, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: MenuBar(
              style: MenuStyle(
                backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
                elevation: const WidgetStatePropertyAll(0),
                padding: const WidgetStatePropertyAll(EdgeInsets.zero),
              ),
              children: [
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: _controller.clear,
                      child: const Text('New (empty)'),
                    ),
                    SubmenuButton(
                      menuChildren: [
                        for (final name in templates.keys)
                          MenuItemButton(
                            onPressed: () => _controller.replaceRoot(
                              templates[name]!,
                              reason: 'new document from template "$name"',
                            ),
                            child: Text(name),
                          ),
                      ],
                      child: const Text('New from template'),
                    ),
                    const Divider(),
                    MenuItemButton(
                      onPressed: _import,
                      shortcut: const SingleActivator(LogicalKeyboardKey.keyI, meta: true, shift: true),
                      child: const Text('Import JSON…'),
                    ),
                    MenuItemButton(
                      onPressed: _export,
                      shortcut: const SingleActivator(LogicalKeyboardKey.keyE, meta: true, shift: true),
                      child: const Text('Export JSON…'),
                    ),
                    MenuItemButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: _controller.prettyJson));
                        ConsoleLog.instance.info('JSON copied to clipboard');
                      },
                      child: const Text('Copy JSON to clipboard'),
                    ),
                  ],
                  child: const Text('File'),
                ),
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: _controller.canUndo ? _controller.undo : null,
                      shortcut: const SingleActivator(LogicalKeyboardKey.keyZ, meta: true),
                      child: const Text('Undo'),
                    ),
                    MenuItemButton(
                      onPressed: _controller.canRedo ? _controller.redo : null,
                      shortcut: const SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true),
                      child: const Text('Redo'),
                    ),
                    const Divider(),
                    SubmenuButton(
                      menuChildren: [
                        for (final spec in widgetSpecs.values)
                          if (spec.children != ChildKind.none)
                            MenuItemButton(
                              onPressed: () => _controller.wrapSelected(spec.type),
                              leadingIcon: Icon(iconFor(spec.type), size: 16),
                              child: Text(spec.type),
                            ),
                      ],
                      child: const Text('Wrap selection with'),
                    ),
                    MenuItemButton(
                      onPressed: _controller.duplicateSelected,
                      shortcut: const SingleActivator(LogicalKeyboardKey.keyD, meta: true),
                      child: const Text('Duplicate'),
                    ),
                    MenuItemButton(
                      onPressed: _controller.deleteSelected,
                      shortcut: const SingleActivator(LogicalKeyboardKey.backspace, meta: true),
                      child: const Text('Delete'),
                    ),
                  ],
                  child: const Text('Edit'),
                ),
                SubmenuButton(
                  menuChildren: [
                    CheckboxMenuButton(
                      value: _darkPreview,
                      onChanged: (v) => setState(() => _darkPreview = v ?? false),
                      child: const Text('Dark preview'),
                    ),
                    SubmenuButton(
                      menuChildren: [
                        for (final (w, label) in const [
                          (320.0, '320 · small phone'),
                          (360.0, '360 · phone'),
                          (414.0, '414 · large phone'),
                          (768.0, '768 · tablet'),
                          (0.0, 'Fill canvas'),
                        ])
                          RadioMenuButton<double>(
                            value: w,
                            groupValue: _previewWidth,
                            onChanged: (v) => setState(() => _previewWidth = v ?? 360),
                            child: Text(label),
                          ),
                      ],
                      child: const Text('Preview width'),
                    ),
                    const Divider(),
                    CheckboxMenuButton(
                      value: _showConsole,
                      onChanged: (v) => setState(() => _showConsole = v ?? true),
                      child: const Text('Console'),
                    ),
                    MenuItemButton(
                      onPressed: ConsoleLog.instance.clear,
                      child: const Text('Clear console'),
                    ),
                  ],
                  child: const Text('View'),
                ),
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () => ConsoleLog.instance.info(
                        'Drag a widget from the palette onto a node in the outline '
                        '(container → child, leaf → sibling before it) or onto the canvas '
                        '(→ selected node). Drag outline rows to move them. '
                        'Double-click a palette tile to add it to the selection.',
                      ),
                      child: const Text('How to use'),
                    ),
                  ],
                  child: const Text('Help'),
                ),
              ],
            ),
          ),
          Text(
            'dynamic_widgets builder',
            style: TextStyle(fontSize: 11, color: scheme.outline),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ workspace

  Widget _workspace(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: _leftWidth,
          child: _Sidebar(
            title: 'Widgets',
            child: PalettePanel(controller: _controller),
          ),
        ),
        _VerticalHandle(
          onDrag: (dx) => setState(() => _leftWidth = (_leftWidth + dx).clamp(180.0, 480.0)),
        ),
        Expanded(
          child: _Canvas(
            controller: _controller,
            dark: _darkPreview,
            width: _previewWidth,
          ),
        ),
        _VerticalHandle(
          onDrag: (dx) => setState(() => _rightWidth = (_rightWidth - dx).clamp(240.0, 560.0)),
        ),
        SizedBox(
          width: _rightWidth,
          child: _Sidebar(
            tabs: const ['Outline', 'Inspector', 'JSON'],
            selectedTab: _rightTab,
            onTab: (i) => setState(() => _rightTab = i),
            child: switch (_rightTab) {
              0 => TreePanel(controller: _controller),
              1 => PaletteResolver(
                resolve: (name) =>
                    (_darkPreview ? DarkModeColors() : LightModeColors()).getColorFromName(name, null),
                child: PropertyPanel(controller: _controller),
              ),
              _ => JsonPanel(controller: _controller, onImport: _import),
            },
          ),
        ),
      ],
    );
  }

  Widget _statusBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final node = _controller.selectedNode;
    final path = _controller.selected;

    return Container(
      height: 22,
      color: scheme.surfaceContainerHigh,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Text(
            node == null ? 'no selection' : '${node['type']}  ·  ${path.isEmpty ? 'root' : path.join('/')}',
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
          ),
          const Spacer(),
          Text(
            '${_previewWidth == 0 ? 'fill' : '${_previewWidth.toInt()}px'}  ·  ${_darkPreview ? 'dark' : 'light'}',
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- dialogs

  Future<void> _export() async {
    final json = _controller.prettyJson;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export JSON'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          FilledButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              ConsoleLog.instance.info('JSON copied to clipboard');
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _import() async {
    final text = TextEditingController();
    String? error;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Import JSON'),
          content: SizedBox(
            width: 560,
            child: TextField(
              controller: text,
              maxLines: 16,
              autofocus: true,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: InputDecoration(
                hintText: '{ "type": "column", "children": [ … ] }',
                border: const OutlineInputBorder(),
                errorText: error,
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              child: const Text('Load'),
              onPressed: () {
                try {
                  final parsed = jsonDecode(text.text);
                  if (parsed is! Map<String, dynamic>) {
                    throw const FormatException('Root must be a JSON object');
                  }
                  _controller.replaceRoot(parsed, reason: 'imported JSON (root: ${parsed['type']})');
                  Navigator.pop(context);
                } on FormatException catch (e) {
                  ConsoleLog.instance.error('import failed: ${e.message}');
                  setDialogState(() => error = e.message);
                }
              },
            ),
          ],
        ),
      ),
    );

    text.dispose();
  }
}

// ------------------------------------------------------------------ pieces

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.child,
    this.title,
    this.tabs = const [],
    this.selectedTab = 0,
    this.onTab,
  });

  final String? title;
  final List<String> tabs;
  final int selectedTab;
  final ValueChanged<int>? onTab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Material (not Container) so ListTile-based children paint ink correctly.
    return Material(
      color: scheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 30,
            padding: EdgeInsets.symmetric(horizontal: tabs.isEmpty ? 10 : 0),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
            ),
            child: tabs.isEmpty
                ? Text(
                    (title ?? '').toUpperCase(),
                    style: TextStyle(fontSize: 11, letterSpacing: 1, color: scheme.onSurfaceVariant),
                  )
                : Row(
                    children: [
                      for (var i = 0; i < tabs.length; i++)
                        PanelTab(
                          label: tabs[i],
                          selected: i == selectedTab,
                          onTap: () => onTab?.call(i),
                        ),
                    ],
                  ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _VerticalHandle extends StatelessWidget {
  const _VerticalHandle({required this.onDrag});

  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.resizeColumn,
    child: GestureDetector(
      onHorizontalDragUpdate: (d) => onDrag(d.delta.dx),
      child: Container(width: 5, color: Theme.of(context).colorScheme.outlineVariant),
    ),
  );
}

class _HorizontalHandle extends StatelessWidget {
  const _HorizontalHandle({required this.onDrag});

  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.resizeRow,
    child: GestureDetector(
      onVerticalDragUpdate: (d) => onDrag(d.delta.dy),
      child: Container(height: 5, color: Theme.of(context).colorScheme.outlineVariant),
    ),
  );
}

/// Center: the JSON rendered by the real `JsonWidget.fromType`, inside an
/// optional device frame. Accepts palette drops (→ selected node, else root).
class _Canvas extends StatelessWidget {
  const _Canvas({required this.controller, required this.dark, required this.width});

  final BuilderController controller;
  final bool dark;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: dark ? Brightness.dark : Brightness.light,
      colorSchemeSeed: const Color(0xFF0053CE),
    );

    Widget canvas = Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          Widget rendered;
          try {
            rendered = JsonWidget.fromType(
              context: context,
              json: controller.root,
              arguments: const [
                // Demo of InAppArgument: a column with widget_id "slot" gets this appended.
                InAppArgument(
                  widgetId: 'slot',
                  child: Chip(label: Text('native widget via InAppArgument')),
                ),
              ],
            );
          } catch (e) {
            ConsoleLog.instance.error('render: $e');
            rendered = const SizedBox.shrink();
          }

          if (controller.isEmpty) {
            rendered = SizedBox(
              height: 468,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.widgets_outlined, size: 40, color: context.colors.outline),
                    const SizedBox(height: 12),
                    Text(
                      'Empty screen\nDrag a widget here',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          // Top-aligned so widgets keep their natural size, as in a real screen body.
          return Material(
            color: context.colors.surface,
            child: SingleChildScrollView(
              child: Align(alignment: Alignment.topCenter, child: rendered),
            ),
          );
        },
      ),
    );

    if (width > 0) {
      canvas = Center(
        child: Container(
          width: width,
          constraints: const BoxConstraints(minHeight: 480),
          margin: const EdgeInsets.symmetric(vertical: 24),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Theme.of(context).colorScheme.outline, width: 6),
          ),
          child: canvas,
        ),
      );
    } else {
      canvas = SizedBox.expand(child: canvas);
    }

    return DragTarget<Object>(
      onWillAcceptWithDetails: (d) => d.data is PaletteDrag,
      onAcceptWithDetails: (d) {
        final type = (d.data as PaletteDrag).type;
        if (controller.isEmpty) {
          controller.addChild(const [], type);
        } else if (controller.canAccept(controller.selected)) {
          controller.addChild(controller.selected, type);
        } else if (controller.canAccept(const [])) {
          controller.addChild(const [], type);
        } else {
          controller.dropOn(controller.selected, d.data);
        }
      },
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        final scheme = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            border: Border.all(
              color: hovering ? scheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: width > 0
              ? SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: canvas,
                )
              : canvas,
        );
      },
    );
  }
}
