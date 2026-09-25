import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:flutter/widgets.dart';

final class JsonWidget$SizedBox extends JsonWidget {
  JsonWidget$SizedBox(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) {
    return SizedBox(
      width: parseDouble(json['width']),
      height: parseDouble(json['height']),
      child: childOrNull(json['child'], arguments: arguments),
    );
  }
}
