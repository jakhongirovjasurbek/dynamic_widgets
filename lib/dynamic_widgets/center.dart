import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:flutter/widgets.dart';

final class JsonWidget$Center extends JsonWidget {
  JsonWidget$Center(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) {
    final childJson = json['child'];

    return Center(
      child: childJson is Map<String, dynamic>
          ? JsonWidget.fromType(context: context, json: childJson, arguments: arguments)
          : const SizedBox.shrink(),
    );
  }
}
