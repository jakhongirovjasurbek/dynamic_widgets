/// Describes which JSON fields each `JsonWidgetTypes` value accepts, so the
/// builder can render a property form and validate the tree.
///
/// Keep this in sync with `lib/dynamic_widgets/*.dart` in the package.
library;

enum FieldKind { text, number, integer, color, opacity, edgeInsets, choice }

/// How a widget type holds nested widgets.
enum ChildKind { none, single, multi }

class FieldSpec {
  const FieldSpec(
    this.key, {
    required this.kind,
    this.label,
    this.options = const [],
    this.hint,
  });

  /// JSON key. Dotted keys address nested objects (`decoration.color`).
  final String key;
  final FieldKind kind;
  final String? label;
  final List<String> options;
  final String? hint;

  String get title => label ?? key;

  List<String> get path => key.split('.');
}

class WidgetSpec {
  const WidgetSpec(this.type, {required this.children, this.fields = const []});

  final String type;
  final ChildKind children;
  final List<FieldSpec> fields;

  /// JSON key that stores nested widgets.
  String get childKey => children == ChildKind.multi ? 'children' : 'child';
}

const colorNames = <String>[
  'primary',
  'onPrimary',
  'primaryContainer',
  'onPrimaryContainer',
  'secondary',
  'onSecondary',
  'secondaryContainer',
  'onSecondaryContainer',
  'tertiary',
  'onTertiary',
  'tertiaryContainer',
  'onTertiaryContainer',
  'error',
  'onError',
  'errorContainer',
  'onErrorContainer',
  'surfaceDim',
  'surfaceContainerLowest',
  'onSurface',
  'surfaceContainerLow',
  'surface',
  'surfaceContainer',
  'onSurfaceVariant',
  'outline',
  'surfaceBright',
  'surfaceContainerHigh',
  'surfaceContainerHighest',
  'outlineVariant',
  'primaryFixed',
  'primaryFixedDim',
  'onPrimaryFixed',
  'onPrimaryFixedVariant',
  'secondaryFixed',
  'secondaryFixedDim',
  'onSecondaryFixed',
  'onSecondaryFixedVariant',
  'tertiaryFixed',
  'tertiaryFixedDim',
  'onTertiaryFixed',
  'onTertiaryFixedVariant',
  'inverseSurface',
  'inverseOnSurface',
  'inversePrimary',
  'scrim',
  'shadow',
  'surfaceTint',
  'success',
  'errorText',
  'waiting',
];

const _mainAxis = ['start', 'center', 'end', 'spaceBetween', 'spaceAround', 'spaceEvenly'];
const _crossAxis = ['center', 'start', 'end', 'stretch'];
const _boxAlignment = ['center', 'topLeft', 'topRight', 'bottomLeft', 'bottomRight'];

const _flexFields = [
  FieldSpec('spacing', kind: FieldKind.number),
  FieldSpec('mainAxisAlignment', kind: FieldKind.choice, options: _mainAxis),
  FieldSpec('crossAxisAlignment', kind: FieldKind.choice, options: _crossAxis),
  FieldSpec('mainAxisSize', kind: FieldKind.choice, options: ['max', 'min']),
];

const _edgeInsetsHint = '16  |  vertical,horizontal  |  left,top,right,bottom';

final Map<String, WidgetSpec> widgetSpecs = {
  for (final spec in _specs) spec.type: spec,
};

const List<WidgetSpec> _specs = [
  WidgetSpec(
    'container',
    children: ChildKind.single,
    fields: [
      FieldSpec('width', kind: FieldKind.number),
      FieldSpec('height', kind: FieldKind.number),
      FieldSpec('padding', kind: FieldKind.edgeInsets, hint: _edgeInsetsHint),
      FieldSpec('margin', kind: FieldKind.edgeInsets, hint: _edgeInsetsHint),
      FieldSpec('alignment', kind: FieldKind.choice, options: _boxAlignment),
      FieldSpec('color', kind: FieldKind.color, hint: 'Ignored when decoration is set'),
      FieldSpec('colorOpacity', kind: FieldKind.opacity),
      FieldSpec('decoration.color', kind: FieldKind.color, label: 'decoration → color'),
      FieldSpec(
        'decoration.colorOpacity',
        kind: FieldKind.opacity,
        label: 'decoration → colorOpacity',
      ),
      FieldSpec(
        'decoration.borderRadius',
        kind: FieldKind.number,
        label: 'decoration → borderRadius',
      ),
      FieldSpec('decoration.border.color', kind: FieldKind.color, label: 'border → color'),
      FieldSpec(
        'decoration.border.colorOpacity',
        kind: FieldKind.opacity,
        label: 'border → colorOpacity',
      ),
      FieldSpec('decoration.border.width', kind: FieldKind.number, label: 'border → width'),
    ],
  ),
  WidgetSpec(
    'row',
    children: ChildKind.multi,
    fields: _flexFields,
  ),
  WidgetSpec(
    'column',
    children: ChildKind.multi,
    fields: [
      ..._flexFields,
      FieldSpec(
        'widget_id',
        kind: FieldKind.text,
        hint: 'InAppArgument slot: native widget appended as last child',
      ),
    ],
  ),
  WidgetSpec(
    'stack',
    children: ChildKind.multi,
    fields: [FieldSpec('alignment', kind: FieldKind.choice, options: _boxAlignment)],
  ),
  WidgetSpec(
    'sizedBox',
    children: ChildKind.single,
    fields: [
      FieldSpec('width', kind: FieldKind.number),
      FieldSpec('height', kind: FieldKind.number),
    ],
  ),
  WidgetSpec(
    'padding',
    children: ChildKind.single,
    fields: [FieldSpec('padding', kind: FieldKind.edgeInsets, hint: _edgeInsetsHint)],
  ),
  WidgetSpec('center', children: ChildKind.single),
  WidgetSpec(
    'align',
    children: ChildKind.single,
    fields: [
      FieldSpec(
        'alignment',
        kind: FieldKind.choice,
        options: [
          'center',
          'topLeft',
          'topCenter',
          'topRight',
          'centerLeft',
          'centerRight',
          'bottomLeft',
          'bottomCenter',
          'bottomRight',
        ],
      ),
    ],
  ),
  WidgetSpec(
    'positioned',
    children: ChildKind.single,
    fields: [
      FieldSpec('left', kind: FieldKind.number),
      FieldSpec('top', kind: FieldKind.number),
      FieldSpec('right', kind: FieldKind.number),
      FieldSpec('bottom', kind: FieldKind.number),
      FieldSpec('width', kind: FieldKind.number),
      FieldSpec('height', kind: FieldKind.number),
    ],
  ),
  WidgetSpec(
    'icon',
    children: ChildKind.none,
    fields: [
      FieldSpec('source', kind: FieldKind.text, hint: 'https://…/a.png | assets/a.svg | data:image/png;base64,…'),
      FieldSpec('width', kind: FieldKind.number),
      FieldSpec('height', kind: FieldKind.number),
      FieldSpec('color', kind: FieldKind.color),
      FieldSpec('colorOpacity', kind: FieldKind.opacity),
      FieldSpec(
        'fit',
        kind: FieldKind.choice,
        options: ['contain', 'cover', 'fill', 'fitWidth', 'fitHeight', 'scaleDown', 'none'],
      ),
      FieldSpec(
        'blend_mode',
        kind: FieldKind.choice,
        options: [
          'srcIn',
          'src',
          'clear',
          'difference',
          'color',
          'colorBurn',
          'colorDodge',
          'darken',
          'dst',
          'dstATop',
          'dstIn',
          'dstOut',
          'exclusion',
          'hardLight',
          'hue',
          'lighten',
          'luminosity',
        ],
      ),
    ],
  ),
  WidgetSpec(
    'text',
    children: ChildKind.none,
    fields: [
      FieldSpec('title', kind: FieldKind.text),
      FieldSpec('size', kind: FieldKind.number),
      FieldSpec('height', kind: FieldKind.number, hint: 'line height multiplier'),
      FieldSpec('color', kind: FieldKind.color),
      FieldSpec('colorOpacity', kind: FieldKind.opacity),
      FieldSpec(
        'fontWeight',
        kind: FieldKind.choice,
        options: [
          'normal',
          'bold',
          'w100',
          'w200',
          'w300',
          'w400',
          'w500',
          'w600',
          'w700',
          'w800',
          'w900',
        ],
      ),
      FieldSpec(
        'textAlign',
        kind: FieldKind.choice,
        options: ['left', 'center', 'right', 'justify'],
      ),
      FieldSpec('maxLines', kind: FieldKind.integer),
      FieldSpec('overflow', kind: FieldKind.choice, options: ['ellipsis', 'fade', 'clip']),
    ],
  ),
  WidgetSpec(
    'expanded',
    children: ChildKind.single,
    fields: [FieldSpec('flex', kind: FieldKind.integer)],
  ),
  WidgetSpec(
    'singleChildScrollView',
    children: ChildKind.single,
    fields: [FieldSpec('padding', kind: FieldKind.edgeInsets, hint: _edgeInsetsHint)],
  ),
  WidgetSpec(
    'backDropFilter',
    children: ChildKind.single,
    fields: [
      FieldSpec('sigmaX', kind: FieldKind.number),
      FieldSpec('sigmaY', kind: FieldKind.number),
    ],
  ),
  WidgetSpec(
    'clipRRect',
    children: ChildKind.single,
    fields: [FieldSpec('borderRadius', kind: FieldKind.number)],
  ),
];

/// Starter templates shown in the "New" menu.
const Map<String, Map<String, dynamic>> templates = {
  'Banner card': {
    'type': 'container',
    'margin': 16,
    'padding': '16, 20',
    'decoration': {
      'color': 'primaryContainer',
      'borderRadius': 16,
    },
    'child': {
      'type': 'column',
      'spacing': 8,
      'crossAxisAlignment': 'start',
      'mainAxisSize': 'min',
      'children': [
        {
          'type': 'text',
          'title': 'Welcome back 👋',
          'size': 20,
          'fontWeight': 'w700',
          'color': 'onPrimaryContainer',
        },
        {
          'type': 'text',
          'title': 'Your dashboard is rendered from JSON.',
          'size': 14,
          'color': 'onPrimaryContainer',
          'colorOpacity': 0.8,
        },
        {
          'type': 'row',
          'spacing': 8,
          'children': [
            {
              'type': 'container',
              'padding': '6, 12',
              'decoration': {'color': 'onPrimaryContainer', 'borderRadius': 999},
              'child': {
                'type': 'text',
                'title': 'Open',
                'size': 12,
                'fontWeight': 'w600',
                'color': 'primaryContainer',
              },
            },
            {
              'type': 'container',
              'padding': '6, 12',
              'decoration': {
                'borderRadius': 999,
                'border': {'color': 'onPrimaryContainer', 'width': 1},
              },
              'child': {
                'type': 'text',
                'title': 'Later',
                'size': 12,
                'color': 'onPrimaryContainer',
              },
            },
          ],
        },
      ],
    },
  },
  'Stack with badge': {
    'type': 'sizedBox',
    'width': 200,
    'height': 120,
    'child': {
      'type': 'stack',
      'children': [
        {
          'type': 'container',
          'decoration': {'color': 'secondaryContainer', 'borderRadius': 12},
          'child': {
            'type': 'center',
            'child': {'type': 'text', 'title': 'Card', 'color': 'onSecondaryContainer'},
          },
        },
        {
          'type': 'positioned',
          'top': 8,
          'right': 8,
          'child': {
            'type': 'container',
            'padding': '2, 8',
            'decoration': {'color': 'error', 'borderRadius': 999},
            'child': {'type': 'text', 'title': 'NEW', 'size': 10, 'color': 'onError'},
          },
        },
      ],
    },
  },
};
