import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dynamic_widgets_method_channel.dart';

abstract class DynamicWidgetsPlatform extends PlatformInterface {
  /// Constructs a DynamicWidgetsPlatform.
  DynamicWidgetsPlatform() : super(token: _token);

  static final Object _token = Object();

  static DynamicWidgetsPlatform _instance = MethodChannelDynamicWidgets();

  /// The default instance of [DynamicWidgetsPlatform] to use.
  ///
  /// Defaults to [MethodChannelDynamicWidgets].
  static DynamicWidgetsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DynamicWidgetsPlatform] when
  /// they register themselves.
  static set instance(DynamicWidgetsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
