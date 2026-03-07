import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:flutter/widgets.dart';

final class JsonWidget$Stack extends JsonWidget {
  JsonWidget$Stack(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) => Stack(
    alignment: _alignment(json['alignment']),
    children: _children(json, arguments: arguments),
  );

  Alignment _alignment(dynamic v) {
    switch (v) {
      case 'topLeft':
        return Alignment.topLeft;
      case 'topRight':
        return Alignment.topRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomRight':
        return Alignment.bottomRight;
      default:
        return Alignment.center;
    }
  }

  List<Widget> _children(Map<String, dynamic> json, {List<InAppArgument>? arguments}) {
    final raw = json['children'];

    if (raw is! List) return const [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (childJson) =>
              JsonWidget.fromType(context: context, json: childJson, arguments: arguments),
        )
        .toList();
  }
}
