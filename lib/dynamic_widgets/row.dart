import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:flutter/widgets.dart';

final class JsonWidget$Row extends JsonWidget {
  JsonWidget$Row(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) => Row(
    spacing: fromIntToDouble(json['spacing']) ?? 0.0,
    mainAxisAlignment: _mainAxis(json['mainAxisAlignment']),
    crossAxisAlignment: _crossAxis(json['crossAxisAlignment']),
    mainAxisSize: json['mainAxisSize'] == 'min' ? MainAxisSize.min : MainAxisSize.max,
    children: childrenFrom(json['children'], arguments: arguments),
  );

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
