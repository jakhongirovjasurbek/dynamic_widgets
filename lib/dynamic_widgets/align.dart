import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:flutter/material.dart';

final class JsonWidget$Align extends JsonWidget {
  JsonWidget$Align(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) => Align(
    alignment: getAlignment(json['alignment']),
    child: childOrEmpty(json['child'], arguments: arguments),
  );

  Alignment getAlignment(dynamic json) {
    if (json == null) {
      return Alignment.center;
    }

    if (json is String) {
      return switch (json) {
        'center' => Alignment.center,
        'bottomCenter' => Alignment.bottomCenter,
        'topCenter' => Alignment.topCenter,
        'centerRight' => Alignment.centerRight,
        'centerLeft' => Alignment.centerLeft,
        'bottomLeft' => Alignment.bottomLeft,
        'topLeft' => Alignment.topLeft,
        'topRight' => Alignment.topRight,
        _ => Alignment.center,
      };
    }

    if (json is Map) {
      final x = parseDouble(json['x']);
      final y = parseDouble(json['y']);

      if (x != null && y != null) return Alignment(x, y);
    }

    return Alignment.center;
  }
}
