import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:flutter/widgets.dart';

final class JsonWidget$Expanded extends JsonWidget {
  JsonWidget$Expanded(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) {
    final childJson = json['child'];

    return Expanded(
      flex: _int(json['flex']) ?? 1,
      child: childJson is Map<String, dynamic>
          ? JsonWidget.fromType(context: context, json: childJson, arguments: arguments)
          : const SizedBox.shrink(),
    );
  }

  int? _int(dynamic v) => v == null ? null : int.tryParse(v.toString());
}
