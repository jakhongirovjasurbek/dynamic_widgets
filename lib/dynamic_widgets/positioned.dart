import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:flutter/widgets.dart';

final class JsonWidget$Positioned extends JsonWidget {
  JsonWidget$Positioned(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) {
    return Positioned(
      left: parseDouble(json['left']),
      top: parseDouble(json['top']),
      right: parseDouble(json['right']),
      bottom: parseDouble(json['bottom']),
      width: parseDouble(json['width']),
      height: parseDouble(json['height']),
      child: childOrEmpty(json['child'], arguments: arguments),
    );
  }
}
