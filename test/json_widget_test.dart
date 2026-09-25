import 'package:dynamic_widgets/dynamic_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<BuildContext> _pump(WidgetTester tester, Widget Function(BuildContext) builder) async {
  late BuildContext ctx;

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          ctx = context;
          return builder(context);
        },
      ),
    ),
  );

  return ctx;
}

void main() {
  testWidgets('unknown type renders empty box instead of throwing', (tester) async {
    await _pump(
      tester,
      (context) => JsonWidget.fromType(context: context, json: {'type': 'doesNotExist'}),
    );

    expect(find.byType(SizedBox), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty json and missing type render empty box', (tester) async {
    await _pump(
      tester,
      (context) => Column(
        children: [
          JsonWidget.fromType(context: context, json: {}),
          JsonWidget.fromType(context: context, json: {'child': {}}),
        ],
      ),
    );

    expect(find.byType(SizedBox), findsNWidgets(2));
  });

  testWidgets('column renders children and accepts title/value/data for text', (tester) async {
    await _pump(
      tester,
      (context) => JsonWidget.fromType(
        context: context,
        json: {
          'type': 'column',
          'children': [
            {'type': 'text', 'title': 'A'},
            {'type': 'text', 'value': 'B'},
            {'type': 'text', 'data': 'C'},
            'not a widget',
          ],
        },
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('column with arguments but no matching widget_id does not crash', (tester) async {
    await _pump(
      tester,
      (context) => JsonWidget.fromType(
        context: context,
        json: {
          'type': 'column',
          'widget_id': 'missing',
          'children': [
            {'type': 'text', 'title': 'only'},
          ],
        },
        arguments: const [InAppArgument(widgetId: 'other', child: Text('injected'))],
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('only'), findsOneWidget);
    expect(find.text('injected'), findsNothing);
  });

  testWidgets('column injects argument child by widget_id', (tester) async {
    await _pump(
      tester,
      (context) => JsonWidget.fromType(
        context: context,
        json: {'type': 'column', 'widget_id': 'slot'},
        arguments: const [InAppArgument(widgetId: 'slot', child: Text('injected'))],
      ),
    );

    expect(find.text('injected'), findsOneWidget);
  });

  testWidgets('text fontWeight w300 maps to FontWeight.w300', (tester) async {
    await _pump(
      tester,
      (context) => JsonWidget.fromType(
        context: context,
        json: {'type': 'text', 'title': 'x', 'fontWeight': 'w300', 'maxLines': '2'},
      ),
    );

    final text = tester.widget<Text>(find.text('x'));
    expect(text.style?.fontWeight, FontWeight.w300);
    expect(text.maxLines, 2);
  });

  testWidgets('container parses padding formats and ignores malformed ones', (tester) async {
    await _pump(
      tester,
      (context) => JsonWidget.fromType(
        context: context,
        json: {
          'type': 'column',
          'children': [
            {'type': 'container', 'padding': 8},
            {'type': 'container', 'padding': '4, 6'},
            {'type': 'container', 'padding': '1,2,3,4'},
            {'type': 'container', 'padding': 'abc'},
          ],
        },
      ),
    );

    final containers = tester.widgetList<Container>(find.byType(Container)).toList();
    expect(containers[0].padding, const EdgeInsets.all(8));
    expect(containers[1].padding, const EdgeInsets.symmetric(vertical: 4, horizontal: 6));
    expect(containers[2].padding, const EdgeInsets.fromLTRB(1, 2, 3, 4));
    expect(containers[3].padding, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('align accepts x/y map and child-less widgets do not crash', (tester) async {
    await _pump(
      tester,
      (context) => JsonWidget.fromType(
        context: context,
        json: {
          'type': 'column',
          'children': [
            {
              'type': 'align',
              'alignment': {'x': 1, 'y': -1},
            },
            {'type': 'clipRRect', 'borderRadius': 8},
            {'type': 'backDropFilter', 'sigmaX': 2},
            {'type': 'expanded', 'flex': '3'},
          ],
        },
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.widget<Align>(find.byType(Align)).alignment, const Alignment(1, -1));
    expect(tester.widget<Expanded>(find.byType(Expanded)).flex, 3);
  });

  testWidgets('icon blend modes dst and lighten resolve', (tester) async {
    await _pump(
      tester,
      (context) => JsonWidget.fromType(
        context: context,
        json: {
          'type': 'row',
          'children': [
            // Unsupported extension: CustomImage renders nothing, no asset load attempted.
            {'type': 'icon', 'source': 'assets/a.txt', 'blend_mode': 'dst'},
            {'type': 'icon', 'source': 'assets/b.txt', 'blend_mode': 'lighten'},
          ],
        },
      ),
    );

    final images = tester.widgetList<CustomImage>(find.byType(CustomImage)).toList();
    expect(images[0].blendMode, BlendMode.dst);
    expect(images[1].blendMode, BlendMode.lighten);
  });

  testWidgets('base64 data URI renders via Image.memory', (tester) async {
    // 1x1 transparent PNG.
    const png =
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

    await _pump(
      tester,
      (context) => JsonWidget.fromType(
        context: context,
        json: {'type': 'icon', 'source': png, 'width': 1, 'height': 1},
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
