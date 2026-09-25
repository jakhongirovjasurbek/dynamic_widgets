import 'package:dynamic_widgets/colors/primitive_colors.dart';
import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:dynamic_widgets/extensions/context_extension.dart';
import 'package:flutter/material.dart';

final class JsonWidget$Text extends JsonWidget {
  JsonWidget$Text(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) => Text(
    (json['title'] ?? json['value'] ?? json['data'])?.toString() ?? '',
    textAlign: _textAlign(json['textAlign']),
    maxLines: parseInt(json['maxLines']),
    overflow: _overflow(json['overflow']),
    style: TextStyle(
      height: parseDouble(json['height']),
      fontSize: parseDouble(json['size']),
      color: context.colors.getColorFromName(json['color'], parseDouble(json['colorOpacity'])),
      fontWeight: weight(json['fontWeight']),
    ),
  );

  FontWeight? weight(dynamic v) {
    if (v == null) return null;

    switch (v.toString()) {
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      case 'normal':
        return FontWeight.normal;
      case 'bold':
        return FontWeight.bold;
    }

    return null;
  }

  TextAlign? _textAlign(dynamic v) {
    switch (v) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'left':
        return TextAlign.left;
      case 'justify':
        return TextAlign.justify;
    }
    return null;
  }

  TextOverflow? _overflow(dynamic v) {
    switch (v) {
      case 'ellipsis':
        return TextOverflow.ellipsis;
      case 'fade':
        return TextOverflow.fade;
      case 'clip':
        return TextOverflow.clip;
    }
    return null;
  }
}
