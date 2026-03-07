import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:flutter/material.dart';

final class JsonWidget$ClipRRect extends JsonWidget {
  JsonWidget$ClipRRect(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) => ClipRRect(
    borderRadius: json['borderRadius'] != null
        ? BorderRadius.circular(_double(json['borderRadius']) ?? 0)
        : BorderRadius.zero,
    child: JsonWidget.fromType(context: context, json: json['child'], arguments: arguments),
  );

  double? _double(dynamic v) => v == null ? null : double.tryParse(v.toString());
}
