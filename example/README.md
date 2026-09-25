# dynamic_widgets example — Visual Builder

A desktop-style GUI for building `dynamic_widgets` JSON.

```bash
flutter run -d chrome
# or
flutter run -d macos
```

```
┌ File · Edit · View · Help ─────────────────────────────────────┐
│ WIDGETS (palette) │        CANVAS (live render)     │ INSPECTOR │
│ OUTLINE (tree)    │                                 │           │
├ CONSOLE / JSON ────────────────────────────────────────────────┤
└ status bar ────────────────────────────────────────────────────┘
```

- **Palette → Outline**: drop on a container node to add a child, on a leaf
  to insert before it. **Palette → Canvas**: adds to the selected node (or
  root). Double-click a tile to add it to the selection.
- **Outline rows** are draggable: move nodes between parents.
- **Inspector** fields update the canvas live; one edit = one undo step.
  *Raw JSON (this node)* edits keys the form does not expose (e.g. `boxShadow`).
- **Console** logs every action and Flutter layout errors from the rendered
  tree (e.g. `Positioned` outside a `Stack`). The **JSON** tab shows the live
  document with a copy button.
- **Menu**: File (templates, import, export, copy), Edit (undo/redo, wrap,
  duplicate, delete), View (dark preview, preview width, console).
- Shortcuts: ⌘Z / ⇧⌘Z undo/redo, ⌘D duplicate, ⌘⌫ delete, ⇧⌘E export, ⇧⌘I import
  (Ctrl on Windows/Linux).
- Sidebars and console are resizable by dragging the dividers.

Property forms come from `lib/builder/schema.dart`; keep it in sync with the
package's `lib/dynamic_widgets/*.dart` parsers.
