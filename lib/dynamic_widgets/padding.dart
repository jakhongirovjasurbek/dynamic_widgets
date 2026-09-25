import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:flutter/widgets.dart';

final class JsonWidget$Padding extends JsonWidget {
  JsonWidget$Padding(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) {
    return Padding(
      padding: parseEdgeInsets(json['padding']) ?? EdgeInsets.zero,
      child: childOrEmpty(json['child'], arguments: arguments),
    );
  }
}
