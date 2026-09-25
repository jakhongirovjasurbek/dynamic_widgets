import 'package:dynamic_widgets/dynamic_widgets_platform_interface.dart';

export 'package:dynamic_widgets/colors/primitive_colors.dart';
export 'package:dynamic_widgets/colors/light_colors.dart';
export 'package:dynamic_widgets/colors/dark_colors.dart';

export 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
export 'package:dynamic_widgets/dynamic_widgets/align.dart';
export 'package:dynamic_widgets/dynamic_widgets/back_drop_filter.dart';
export 'package:dynamic_widgets/dynamic_widgets/center.dart';
export 'package:dynamic_widgets/dynamic_widgets/clip_r_rect.dart';
export 'package:dynamic_widgets/dynamic_widgets/column.dart';
export 'package:dynamic_widgets/dynamic_widgets/container.dart';
export 'package:dynamic_widgets/dynamic_widgets/custom_image.dart';
export 'package:dynamic_widgets/dynamic_widgets/expanded.dart';
export 'package:dynamic_widgets/dynamic_widgets/padding.dart';
export 'package:dynamic_widgets/dynamic_widgets/positioned.dart';
export 'package:dynamic_widgets/dynamic_widgets/row.dart';
export 'package:dynamic_widgets/dynamic_widgets/single_child_scroll_view.dart';
export 'package:dynamic_widgets/dynamic_widgets/sized_box.dart';
export 'package:dynamic_widgets/dynamic_widgets/stack.dart';
export 'package:dynamic_widgets/dynamic_widgets/text.dart';

export 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
export 'package:dynamic_widgets/dynamic_widgets/types/actions.dart';
export 'package:dynamic_widgets/dynamic_widgets/types/types.dart';

export 'package:dynamic_widgets/extensions/color_extension.dart';
export 'package:dynamic_widgets/extensions/context_extension.dart';

export 'package:dynamic_widgets/widgets/custom_image.dart';

/// Entry point of the plugin.
///
/// Rendering is done with [JsonWidget.fromType]; this class only exposes the
/// native platform channel.
class DynamicWidgets {
  Future<String?> getPlatformVersion() => DynamicWidgetsPlatform.instance.getPlatformVersion();
}
