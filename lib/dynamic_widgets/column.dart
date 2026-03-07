import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:flutter/widgets.dart';

final class JsonWidget$Column extends JsonWidget {
  JsonWidget$Column(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) {
    final argument = arguments?.firstWhere((item) => item.widgetId == json['widget_id']);

    return Column(
      spacing: fromIntToDouble(json['spacing']) ?? 0.0,
      mainAxisAlignment: _mainAxis(json['mainAxisAlignment']),
      crossAxisAlignment: _crossAxis(json['crossAxisAlignment']),
      mainAxisSize: json['mainAxisSize'] == 'min' ? MainAxisSize.min : MainAxisSize.max,
      children: [
        ..._children(json, arguments: arguments),
        if (argument?.child != null) argument!.child,
      ],
    );
  }

  List<Widget> _children(Map<String, dynamic> json, {List<InAppArgument>? arguments}) {
    final list = json['children'];

    if (list is! List) return const [];

    return list
        .whereType<Map<String, dynamic>>()
        .map(
          (childJson) =>
              JsonWidget.fromType(context: context, json: childJson, arguments: arguments),
        )
        .toList();
  }

  MainAxisAlignment _mainAxis(dynamic v) {
    switch (v) {
      case 'center':
        return MainAxisAlignment.center;
      case 'end':
        return MainAxisAlignment.end;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
    }

    return MainAxisAlignment.start;
  }

  CrossAxisAlignment _crossAxis(dynamic v) {
    switch (v) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'stretch':
        return CrossAxisAlignment.stretch;
    }

    return CrossAxisAlignment.center;
  }
}
