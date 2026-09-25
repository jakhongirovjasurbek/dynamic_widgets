import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'console.dart';
import 'schema.dart';

/// Drag payload from the widget palette: a `JsonWidgetTypes` name.
class PaletteDrag {
  const PaletteDrag(this.type);
  final String type;
}

/// Drag payload from the outline: an existing node being moved.
class NodeDrag {
  const NodeDrag(this.path);
  final NodePath path;
}

/// A path from the root to a node: alternating `'child'` / `'children'` keys
/// and list indexes, e.g. `['child', 'children', 2]`.
typedef NodePath = List<Object>;

/// Owns the JSON document being edited, the selection and undo history.
class BuilderController extends ChangeNotifier {
  /// [initial] is deep-copied through JSON so typed Dart literals
  /// (`List<Map<String, String>>`) become plain `List<dynamic>` trees.
  /// Without [initial] the document starts empty (`{}`): no widget at all.
  BuilderController({Map<String, dynamic>? initial}) : _root = _clone(initial ?? const {});

  Map<String, dynamic> _root;
  NodePath _selected = const [];
  final List<String> _undo = [];
  final List<String> _redo = [];

  final ConsoleLog _log = ConsoleLog.instance;

  Map<String, dynamic> get root => _root;

  /// True when no root widget has been placed yet.
  bool get isEmpty => _root['type'] == null;
  NodePath get selected => _selected;
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  String get prettyJson => const JsonEncoder.withIndent('  ').convert(_root);

  // ---------------------------------------------------------------- lookup

  Map<String, dynamic>? nodeAt(NodePath path) {
    if (isEmpty) return null;

    dynamic cursor = _root;

    for (final segment in path) {
      if (segment is String && cursor is Map) {
        cursor = cursor[segment];
      } else if (segment is int && cursor is List) {
        if (segment < 0 || segment >= cursor.length) return null;
        cursor = cursor[segment];
      } else {
        return null;
      }
    }

    return cursor is Map<String, dynamic> ? cursor : null;
  }

  Map<String, dynamic>? get selectedNode => nodeAt(_selected);

  WidgetSpec? specOf(Map<String, dynamic>? node) =>
      node == null ? null : widgetSpecs[node['type']?.toString()];

  /// Children of [node] as (path, node) pairs, for either child kind.
  List<(NodePath, Map<String, dynamic>)> childrenOf(NodePath path, Map<String, dynamic> node) {
    final spec = specOf(node);

    if (spec == null) return const [];

    switch (spec.children) {
      case ChildKind.none:
        return const [];
      case ChildKind.single:
        final child = node['child'];
        return child is Map<String, dynamic> ? [([...path, 'child'], child)] : const [];
      case ChildKind.multi:
        final list = node['children'];
        if (list is! List) return const [];
        return [
          for (var i = 0; i < list.length; i++)
            if (list[i] is Map<String, dynamic>) ([...path, 'children', i], list[i]),
        ];
    }
  }

  // ------------------------------------------------------------- selection

  void select(NodePath path) {
    _selected = List.unmodifiable(path);
    notifyListeners();
  }

  // ------------------------------------------------------------- mutation

  void _commit(void Function() edit, {bool recordUndo = true}) {
    if (recordUndo) snapshot();
    edit();
    if (nodeAt(_selected) == null) _selected = const [];
    notifyListeners();
  }

  /// Pushes the current document onto the undo stack without changing it.
  /// Text fields call this once when editing starts, then stream changes
  /// with `recordUndo: false`, so one edit session equals one undo step.
  void snapshot() {
    _undo.add(jsonEncode(_root));
    _redo.clear();
  }

  void undo() {
    if (_undo.isEmpty) return;
    _redo.add(jsonEncode(_root));
    _root = jsonDecode(_undo.removeLast()) as Map<String, dynamic>;
    if (nodeAt(_selected) == null) _selected = const [];
    _log.info('undo');
    notifyListeners();
  }

  void redo() {
    if (_redo.isEmpty) return;
    _undo.add(jsonEncode(_root));
    _root = jsonDecode(_redo.removeLast()) as Map<String, dynamic>;
    if (nodeAt(_selected) == null) _selected = const [];
    _log.info('redo');
    notifyListeners();
  }

  void replaceRoot(Map<String, dynamic> json, {String? reason}) => _commit(() {
    _root = _clone(json);
    _selected = const [];
    _log.info(reason ?? 'document replaced (root: ${json['type']})');
  });

  /// Clears the document back to "no widget".
  void clear() => replaceRoot(const {}, reason: 'document cleared');

  /// Sets a (possibly dotted) field on the selected node. `null` or an empty
  /// string removes it; empty parent objects are pruned.
  void setField(List<String> keys, Object? value, {bool recordUndo = true}) {
    final node = selectedNode;
    if (node == null) return;

    _commit(recordUndo: recordUndo, () {
      if (value == null || (value is String && value.isEmpty)) {
        _remove(node, keys);
      } else {
        var cursor = node;
        for (final key in keys.sublist(0, keys.length - 1)) {
          final next = cursor[key];
          if (next is Map<String, dynamic>) {
            cursor = next;
          } else {
            cursor = cursor[key] = <String, dynamic>{};
          }
        }
        cursor[keys.last] = value;
      }
    });
  }

  void _remove(Map<String, dynamic> node, List<String> keys) {
    if (keys.length == 1) {
      node.remove(keys.first);
      return;
    }
    final next = node[keys.first];
    if (next is Map<String, dynamic>) {
      _remove(next, keys.sublist(1));
      if (next.isEmpty) node.remove(keys.first);
    }
  }

  /// Replaces the selected node's JSON wholesale (raw editor).
  void replaceSelected(Map<String, dynamic> json) {
    if (_selected.isEmpty) {
      replaceRoot(json);
      return;
    }
    _commit(() => _setAt(_selected, _clone(json)));
  }

  /// Whether [parentPath] can receive one more child. An empty document
  /// accepts a root at path `[]`.
  bool canAccept(NodePath parentPath) {
    if (isEmpty) return parentPath.isEmpty;

    final parent = nodeAt(parentPath);
    final spec = specOf(parent);
    if (parent == null || spec == null) return false;
    return switch (spec.children) {
      ChildKind.none => false,
      ChildKind.single => parent['child'] is! Map,
      ChildKind.multi => true,
    };
  }

  static Map<String, dynamic> newNode(String type) {
    final child = <String, dynamic>{'type': type};
    if (widgetSpecs[type]?.children == ChildKind.multi) child['children'] = <dynamic>[];
    if (type == 'text') child['title'] = 'Text';
    if (type == 'icon') child['source'] = 'assets/icon.png';
    return child;
  }

  void addChild(NodePath parentPath, String type) => insertChild(parentPath, newNode(type));

  /// Inserts [node] under [parentPath]; for list parents at [index] (append
  /// when null). Logs and does nothing when the parent cannot take a child.
  void insertChild(NodePath parentPath, Map<String, dynamic> node, {int? index}) {
    if (isEmpty) {
      if (parentPath.isNotEmpty) return;
      _commit(() {
        _root = node;
        _selected = const [];
        _log.info('placed ${node['type']} as root');
      });
      return;
    }

    final parent = nodeAt(parentPath);
    final spec = specOf(parent);
    if (parent == null || spec == null) return;

    if (spec.children == ChildKind.none) {
      _log.warn('${spec.type} cannot have children');
      return;
    }
    if (spec.children == ChildKind.single && parent['child'] is Map) {
      _log.warn('${spec.type} already has a child; drop onto an empty slot or wrap instead');
      return;
    }

    _commit(() {
      if (spec.children == ChildKind.single) {
        parent['child'] = node;
        _selected = [...parentPath, 'child'];
      } else {
        final list = parent['children'] is List ? parent['children'] as List : <dynamic>[];
        final at = (index ?? list.length).clamp(0, list.length);
        list.insert(at, node);
        parent['children'] = list;
        _selected = [...parentPath, 'children', at];
      }
      _log.info('added ${node['type']} → ${_describe(parentPath)}');
    });
  }

  /// Drops [payload] (palette type or existing node) onto [target].
  ///
  /// A container target receives the item as a child; a leaf target receives
  /// it as a sibling placed before itself.
  void dropOn(NodePath target, Object payload) {
    if (isEmpty) {
      if (payload is PaletteDrag) insertChild(const [], newNode(payload.type));
      return;
    }

    final targetNode = nodeAt(target);
    final spec = specOf(targetNode);
    if (targetNode == null || spec == null) return;

    final NodePath parentPath;
    final int? index;

    if (spec.children != ChildKind.none) {
      parentPath = target;
      index = null;
    } else if (target.isNotEmpty && target.last is int) {
      parentPath = target.sublist(0, target.length - 2);
      index = target.last as int;
    } else {
      _log.warn('${spec.type} cannot have children');
      return;
    }

    switch (payload) {
      case PaletteDrag(:final type):
        insertChild(parentPath, newNode(type), index: index);
      case NodeDrag(:final path):
        moveNode(path, parentPath, index: index);
    }
  }

  /// Moves the node at [from] under [toParent]. Refuses moves into itself.
  void moveNode(NodePath from, NodePath toParent, {int? index}) {
    if (from.isEmpty) {
      _log.warn('cannot move the root node');
      return;
    }
    if (_startsWith(toParent, from)) {
      _log.warn('cannot move a node into itself');
      return;
    }
    final node = nodeAt(from);
    if (node == null) return;
    if (!canAccept(toParent) && !(specOf(nodeAt(toParent))?.children == ChildKind.multi)) {
      _log.warn('${nodeAt(toParent)?['type']} cannot take another child');
      return;
    }

    _commit(() {
      final moved = _clone(node);
      _detach(from);

      // Removing from a list shifts later siblings; fix the destination path.
      var dest = List<Object>.of(toParent);
      var at = index;
      final fromLast = from.last;
      if (fromLast is int) {
        final listPrefix = from.sublist(0, from.length - 1); // […, 'children']
        if (_startsWith(dest, listPrefix) && dest.length > listPrefix.length) {
          final i = dest[listPrefix.length];
          if (i is int && i > fromLast) dest[listPrefix.length] = i - 1;
        }
        if (at != null && _samePath(dest, from.sublist(0, from.length - 2)) && at > fromLast) {
          at -= 1;
        }
      }

      final parent = nodeAt(dest)!;
      final spec = specOf(parent)!;
      if (spec.children == ChildKind.single) {
        parent['child'] = moved;
        _selected = [...dest, 'child'];
      } else {
        final list = parent['children'] is List ? parent['children'] as List : <dynamic>[];
        final pos = (at ?? list.length).clamp(0, list.length);
        list.insert(pos, moved);
        parent['children'] = list;
        _selected = [...dest, 'children', pos];
      }
      _log.info('moved ${moved['type']} → ${_describe(dest)}');
    });
  }

  void _detach(NodePath path) {
    final last = path.last;
    if (last is int) {
      final list = nodeAt(path.sublist(0, path.length - 2))?['children'];
      if (list is List) list.removeAt(last);
    } else {
      nodeAt(path.sublist(0, path.length - 1))?.remove('child');
    }
  }

  String _describe(NodePath path) =>
      path.isEmpty ? 'root' : '${nodeAt(path)?['type']} @ ${path.join('/')}';

  static bool _startsWith(NodePath path, NodePath prefix) {
    if (path.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (path[i] != prefix[i]) return false;
    }
    return true;
  }

  static bool _samePath(NodePath a, NodePath b) => a.length == b.length && _startsWith(a, b);

  /// Inserts a new node between the selected node and its parent.
  void wrapSelected(String type) {
    final node = selectedNode;
    if (node == null) return;
    final wrapperSpec = widgetSpecs[type];
    if (wrapperSpec == null || wrapperSpec.children == ChildKind.none) return;

    final wrapper = <String, dynamic>{'type': type};
    if (wrapperSpec.children == ChildKind.single) {
      wrapper['child'] = node;
    } else {
      wrapper['children'] = <dynamic>[node];
    }

    _commit(() {
      _setAt(_selected, wrapper);
      _log.info('wrapped ${node['type']} with $type');
    });
  }

  void deleteSelected() {
    if (_selected.isEmpty) {
      if (!isEmpty) clear();
      return;
    }

    final type = selectedNode?['type'];

    _commit(() {
      _log.info('deleted $type');
      final parentPath = _selected.sublist(0, _selected.length - 1);
      final last = _selected.last;

      if (last is int) {
        final list = nodeAt(parentPath.sublist(0, parentPath.length - 1))?['children'];
        if (list is List) list.removeAt(last);
        _selected = parentPath.sublist(0, parentPath.length - 1);
      } else {
        nodeAt(parentPath)?.remove('child');
        _selected = parentPath;
      }
    });
  }

  void moveSelected(int delta) {
    final last = _selected.isEmpty ? null : _selected.last;
    if (last is! int) return;

    final listOwner = _selected.sublist(0, _selected.length - 2);
    final list = nodeAt(listOwner)?['children'];
    if (list is! List) return;

    final target = last + delta;
    if (target < 0 || target >= list.length) return;

    _commit(() {
      final item = list.removeAt(last);
      list.insert(target, item);
      _selected = [..._selected.sublist(0, _selected.length - 1), target];
      _log.info('moved ${item is Map ? item['type'] : 'node'} to index $target');
    });
  }

  void duplicateSelected() {
    final last = _selected.isEmpty ? null : _selected.last;
    final node = selectedNode;
    if (last is! int || node == null) return;

    final list = nodeAt(_selected.sublist(0, _selected.length - 2))?['children'];
    if (list is! List) return;

    _commit(() {
      list.insert(last + 1, _clone(node));
      _selected = [..._selected.sublist(0, _selected.length - 1), last + 1];
      _log.info('duplicated ${node['type']}');
    });
  }

  void _setAt(NodePath path, Map<String, dynamic> value) {
    if (path.isEmpty) {
      _root = value;
      return;
    }
    final parentPath = path.sublist(0, path.length - 1);
    final last = path.last;

    if (last is int) {
      final list = nodeAt(parentPath.sublist(0, parentPath.length - 1))?['children'];
      if (list is List) list[last] = value;
    } else {
      nodeAt(parentPath)?[last as String] = value;
    }
  }

  static Map<String, dynamic> _clone(Map<String, dynamic> json) =>
      jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
}
