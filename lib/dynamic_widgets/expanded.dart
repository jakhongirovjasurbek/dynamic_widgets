import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:flutter/widgets.dart';

final class JsonWidget$Expanded extends JsonWidget {
  JsonWidget$Expanded(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) {
    return Expanded(
      flex: parseInt(json['flex']) ?? 1,
      child: childOrEmpty(json['child'], arguments: arguments),
    );
  }
}
