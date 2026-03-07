import 'package:dynamic_widgets/dynamic_widgets/align.dart';
import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/back_drop_filter.dart';
import 'package:dynamic_widgets/dynamic_widgets/center.dart';
import 'package:dynamic_widgets/dynamic_widgets/clip_r_rect.dart';
import 'package:dynamic_widgets/dynamic_widgets/column.dart';
import 'package:dynamic_widgets/dynamic_widgets/container.dart';
import 'package:dynamic_widgets/dynamic_widgets/custom_image.dart';
import 'package:dynamic_widgets/dynamic_widgets/expanded.dart';
import 'package:dynamic_widgets/dynamic_widgets/padding.dart';
import 'package:dynamic_widgets/dynamic_widgets/positioned.dart';
import 'package:dynamic_widgets/dynamic_widgets/row.dart';
import 'package:dynamic_widgets/dynamic_widgets/single_child_scroll_view.dart';
import 'package:dynamic_widgets/dynamic_widgets/sized_box.dart';
import 'package:dynamic_widgets/dynamic_widgets/stack.dart';
import 'package:dynamic_widgets/dynamic_widgets/text.dart';
import 'package:dynamic_widgets/dynamic_widgets/types/types.dart';
import 'package:flutter/cupertino.dart';

abstract class JsonWidget {
  JsonWidget(this.context);

  final BuildContext context;

  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments});

  static Widget fromType({
    required BuildContext context,
    required Map<String, dynamic> json,
    List<InAppArgument>? arguments,
  }) {
    if (json.isEmpty || json['type'] == null) return const SizedBox();

    return switch (JsonWidgetTypes.values.byName(json['type'])) {
      JsonWidgetTypes.container => JsonWidget$Container(
        context,
      ).fromJson(json, arguments: arguments),
      JsonWidgetTypes.row => JsonWidget$Row(context).fromJson(json, arguments: arguments),
      JsonWidgetTypes.column => JsonWidget$Column(context).fromJson(json, arguments: arguments),
      JsonWidgetTypes.stack => JsonWidget$Stack(context).fromJson(json, arguments: arguments),
      JsonWidgetTypes.sizedBox => JsonWidget$SizedBox(context).fromJson(json, arguments: arguments),
      JsonWidgetTypes.padding => JsonWidget$Padding(context).fromJson(json, arguments: arguments),
      JsonWidgetTypes.center => JsonWidget$Center(context).fromJson(json, arguments: arguments),
      JsonWidgetTypes.align => JsonWidget$Align(context).fromJson(json, arguments: arguments),

      JsonWidgetTypes.positioned => JsonWidget$Positioned(
        context,
      ).fromJson(json, arguments: arguments),
      JsonWidgetTypes.icon => JsonWidget$CustomImage(context).fromJson(json, arguments: arguments),
      JsonWidgetTypes.text => JsonWidget$Text(context).fromJson(json, arguments: arguments),
      JsonWidgetTypes.expanded => JsonWidget$Expanded(context).fromJson(json, arguments: arguments),
      JsonWidgetTypes.singleChildScrollView => JsonWidget$SingleChildScrollView(
        context,
      ).fromJson(json, arguments: arguments),
      JsonWidgetTypes.backDropFilter => JsonWidget$BackDropFilter(
        context,
      ).fromJson(json, arguments: arguments),
      JsonWidgetTypes.clipRRect => JsonWidget$ClipRRect(
        context,
      ).fromJson(json, arguments: arguments),
    };
  }

  double? fromIntToDouble(dynamic value) {
    if (value == null) return null;

    if (value is int) return value.toDouble();

    if (value is double) return value;

    return value;
  }
}
