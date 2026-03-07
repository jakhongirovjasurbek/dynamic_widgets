import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:flutter/widgets.dart';

final class JsonWidget$SizedBox extends JsonWidget {
  JsonWidget$SizedBox(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) {
    final childJson = json['child'];

    return SizedBox(
      width: _double(json['width']),
      height: _double(json['height']),
      child: childJson is Map<String, dynamic>
          ? JsonWidget.fromType(context: context, json: childJson, arguments: arguments)
          : null,
    );
  }

  double? _double(dynamic v) => v == null ? null : double.tryParse(v.toString());
}
