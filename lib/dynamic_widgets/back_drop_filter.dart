import 'dart:ui';

import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:flutter/material.dart';

final class JsonWidget$BackDropFilter extends JsonWidget {
  JsonWidget$BackDropFilter(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) => BackdropFilter(
    filter: ImageFilter.blur(
      sigmaY: parseDouble(json['sigmaY']) ?? 0,
      sigmaX: parseDouble(json['sigmaX']) ?? 0,
    ),
    child: childOrEmpty(json['child'], arguments: arguments),
  );
}
