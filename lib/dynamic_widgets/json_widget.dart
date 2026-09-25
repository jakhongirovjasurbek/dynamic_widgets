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
    if (json.isEmpty || json['type'] == null) return const SizedBox.shrink();

    final type = JsonWidgetTypes.values.asNameMap()[json['type'].toString()];

    // Unknown type (for example a newer server schema): render nothing instead of crashing.
    if (type == null) return const SizedBox.shrink();

    return switch (type) {
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

  /// Parses a JSON value (num or numeric String) into a double.
  /// Returns null when the value is missing or not numeric.
  double? fromIntToDouble(dynamic value) => parseDouble(value);

  double? parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }

  int? parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  /// Parses padding/margin.
  ///
  /// Accepts a number (`16`), or a String with 1, 2 or 4 comma separated
  /// values: `"16"`, `"vertical,horizontal"`, `"left,top,right,bottom"`.
  /// Returns null on any malformed input.
  EdgeInsets? parseEdgeInsets(dynamic value) {
    if (value == null) return null;

    if (value is num) return EdgeInsets.all(value.toDouble());

    if (value is! String) return null;

    final parts = value.split(',').map((e) => double.tryParse(e.trim())).toList();

    if (parts.any((e) => e == null)) return null;

    return switch (parts.length) {
      1 => EdgeInsets.all(parts[0]!),
      2 => EdgeInsets.symmetric(vertical: parts[0]!, horizontal: parts[1]!),
      4 => EdgeInsets.fromLTRB(parts[0]!, parts[1]!, parts[2]!, parts[3]!),
      _ => null,
    };
  }

  /// Builds a child widget when [childJson] is a JSON object, otherwise null.
  Widget? childOrNull(dynamic childJson, {List<InAppArgument>? arguments}) =>
      childJson is Map<String, dynamic>
      ? JsonWidget.fromType(context: context, json: childJson, arguments: arguments)
      : null;

  /// Builds a child widget when [childJson] is a JSON object, otherwise an empty box.
  Widget childOrEmpty(dynamic childJson, {List<InAppArgument>? arguments}) =>
      childOrNull(childJson, arguments: arguments) ?? const SizedBox.shrink();

  /// Builds every JSON object inside [list]; non-object entries are skipped.
  List<Widget> childrenFrom(dynamic list, {List<InAppArgument>? arguments}) {
    if (list is! List) return const [];

    return list
        .whereType<Map<String, dynamic>>()
        .map((j) => JsonWidget.fromType(context: context, json: j, arguments: arguments))
        .toList();
  }
}
