import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_widgets/dynamic_widgets.dart';
import 'package:dynamic_widgets/dynamic_widgets_platform_interface.dart';
import 'package:dynamic_widgets/dynamic_widgets_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDynamicWidgetsPlatform
    with MockPlatformInterfaceMixin
    implements DynamicWidgetsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DynamicWidgetsPlatform initialPlatform = DynamicWidgetsPlatform.instance;

  test('$MethodChannelDynamicWidgets is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDynamicWidgets>());
  });

  test('getPlatformVersion', () async {
    DynamicWidgets dynamicWidgetsPlugin = DynamicWidgets();
    MockDynamicWidgetsPlatform fakePlatform = MockDynamicWidgetsPlatform();
    DynamicWidgetsPlatform.instance = fakePlatform;

    expect(await dynamicWidgetsPlugin.getPlatformVersion(), '42');
  });
}
