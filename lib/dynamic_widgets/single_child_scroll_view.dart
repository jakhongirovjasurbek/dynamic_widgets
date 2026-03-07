import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:flutter/widgets.dart';

final class JsonWidget$SingleChildScrollView extends JsonWidget {
  JsonWidget$SingleChildScrollView(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) {
    final padding = _edgeInsets(json['padding']);

    final childJson = json['child'];

    return SingleChildScrollView(
      padding: padding ?? EdgeInsets.zero,
      child: childJson is Map<String, dynamic>
          ? JsonWidget.fromType(context: context, json: childJson, arguments: arguments)
          : const SizedBox.shrink(),
    );
  }

  EdgeInsets? _edgeInsets(dynamic v) {
    if (v == null) return null;

    if (v is num) return EdgeInsets.all(v.toDouble());

    if (v is String) {
      final parts = v.split(',').map((e) => double.parse(e.trim())).toList();

      if (parts.length == 1) return EdgeInsets.all(parts[0]);

      if (parts.length == 2) {
        return EdgeInsets.symmetric(vertical: parts[0], horizontal: parts[1]);
      }

      if (parts.length == 4) {
        return EdgeInsets.fromLTRB(parts[0], parts[1], parts[2], parts[3]);
      }
    }

    return null;
  }
}
