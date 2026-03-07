import 'dart:ui';

import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:flutter/material.dart';

final class JsonWidget$BackDropFilter extends JsonWidget {
  JsonWidget$BackDropFilter(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) => BackdropFilter(
    filter: ImageFilter.blur(
      sigmaY: _double(json['sigmaY']) ?? 0,
      sigmaX: _double(json['sigmaX']) ?? 0,
    ),
    child: JsonWidget.fromType(context: context, json: json['child'], arguments: arguments),
  );

  double? _double(dynamic v) => v == null ? null : double.tryParse(v.toString());
}
