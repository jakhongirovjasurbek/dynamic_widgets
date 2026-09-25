import 'package:dynamic_widgets_example/builder/builder_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BuilderController make() => BuilderController(
    initial: {
      'type': 'column',
      'children': [
        {'type': 'text', 'title': 'a'},
        {'type': 'text', 'title': 'b'},
      ],
    },
  );

  test('starts empty; first drop becomes root; delete root empties again', () {
    final c = BuilderController();
    expect(c.isEmpty, isTrue);
    expect(c.canAccept(const []), isTrue);
    expect(c.canAccept(const ['child']), isFalse);

    c.dropOn(const [], const PaletteDrag('column'));
    expect(c.isEmpty, isFalse);
    expect(c.root['type'], 'column');

    c.select(const []);
    c.deleteSelected();
    expect(c.isEmpty, isTrue);
    expect(c.prettyJson, '{}');

    c.undo();
    expect(c.root['type'], 'column');
  });

  test('setField writes nested keys and prunes empty objects', () {
    final c = make();
    c.setField(['decoration', 'border', 'width'], 2);
    expect(c.root['decoration'], {
      'border': {'width': 2},
    });

    c.setField(['decoration', 'border', 'width'], null);
    expect(c.root.containsKey('decoration'), isFalse);
  });

  test('undo and redo restore documents; live edits share one step', () {
    final c = make();
    c.snapshot();
    c.setField(['spacing'], 1, recordUndo: false);
    c.setField(['spacing'], 12, recordUndo: false);
    expect(c.root['spacing'], 12);

    c.undo();
    expect(c.root.containsKey('spacing'), isFalse);
    expect(c.canRedo, isTrue);

    c.redo();
    expect(c.root['spacing'], 12);
  });

  test('addChild, moveSelected, duplicate, delete keep selection valid', () {
    final c = make();
    c.addChild(const [], 'icon');
    expect(c.selected, ['children', 2]);
    expect(c.selectedNode?['type'], 'icon');

    c.moveSelected(-1);
    expect(c.selected, ['children', 1]);
    expect((c.root['children'] as List)[1]['type'], 'icon');

    c.duplicateSelected();
    expect((c.root['children'] as List).length, 4);
    expect(c.selected, ['children', 2]);

    c.deleteSelected();
    expect((c.root['children'] as List).length, 3);
    expect(c.selectedNode?['type'], 'column');
  });

  test('wrapSelected inserts a parent and single-child delete clears child', () {
    final c = make();
    c.select(const ['children', 0]);
    c.wrapSelected('padding');

    final wrapped = (c.root['children'] as List)[0] as Map<String, dynamic>;
    expect(wrapped['type'], 'padding');
    expect(wrapped['child']['title'], 'a');

    c.select(const ['children', 0, 'child']);
    c.deleteSelected();
    expect(wrapped.containsKey('child'), isFalse);
    expect(c.selected, ['children', 0]);
  });

  test('dropOn: container gets a child, leaf gets a sibling before it', () {
    final c = make();
    c.dropOn(const [], const PaletteDrag('icon'));
    expect((c.root['children'] as List).last['type'], 'icon');

    c.dropOn(const ['children', 1], const PaletteDrag('sizedBox'));
    expect((c.root['children'] as List)[1]['type'], 'sizedBox');
    expect(c.selected, ['children', 1]);
  });

  test('moveNode reorders within a list and refuses moves into itself', () {
    final c = make();
    // move 'b' (index 1) before 'a' (index 0)
    c.moveNode(const ['children', 1], const [], index: 0);
    final titles = (c.root['children'] as List).map((e) => e['title']).toList();
    expect(titles, ['b', 'a']);

    c.addChild(const [], 'column');
    final wrapperPath = c.selected; // ['children', 2]
    c.moveNode(wrapperPath, wrapperPath); // into itself
    expect((c.root['children'] as List).length, 3);

    // move 'a' (index 1) into the new column (index 2); index shifts to 1 after removal
    c.moveNode(const ['children', 1], wrapperPath);
    expect((c.root['children'] as List).length, 2);
    expect(((c.root['children'] as List)[1]['children'] as List).single['title'], 'a');
  });

  test('replaceSelected with a root path replaces the whole document', () {
    final c = make();
    c.replaceSelected({'type': 'text', 'title': 'x'});
    expect(c.root['type'], 'text');
    c.undo();
    expect(c.root['type'], 'column');
  });
}
