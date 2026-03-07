import 'package:dynamic_widgets/colors/primitive_colors.dart';
import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:dynamic_widgets/extensions/context_extension.dart';
import 'package:dynamic_widgets/widgets/custom_image.dart';
import 'package:flutter/material.dart';

final class JsonWidget$CustomImage extends JsonWidget {
  JsonWidget$CustomImage(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) => CustomImage(
    source: json['source'],
    height: fromIntToDouble(json['height']),
    width: fromIntToDouble(json['width']),
    color: context.colors.getColorFromName(json['color'], _double(json['colorOpacity'])),
    errorWidget: switch (json['errorWidget'] != null) {
      true => JsonWidget.fromType(
        context: context,
        json: json['errorWidget'],
        arguments: arguments,
      ),
      false => null,
    },
    fit: switch (json['fit']) {
      'contain' => BoxFit.contain,
      'fitWidth' => BoxFit.fitWidth,
      'scaleDown' => BoxFit.scaleDown,
      'fitHeight' => BoxFit.fitHeight,
      'fill' => BoxFit.fill,
      'cover' => BoxFit.cover,
      'none' => BoxFit.none,
      _ => BoxFit.contain,
    },
    blendMode: switch (json['blend_mode']) {
      'srcIn' => BlendMode.srcIn,
      'src' => BlendMode.src,
      'clear' => BlendMode.clear,
      'difference' => BlendMode.difference,
      'color' => BlendMode.color,
      'colorBurn' => BlendMode.colorBurn,
      'colorDodge' => BlendMode.colorDodge,
      'darken' => BlendMode.darken,
      'dst,' => BlendMode.dst,
      'dstATop' => BlendMode.dstATop,
      'dstIn' => BlendMode.dstIn,
      'dstOut' => BlendMode.dstOut,
      'exclusion' => BlendMode.exclusion,
      'hardLight' => BlendMode.hardLight,
      'hue' => BlendMode.hue,
      'lighten,' => BlendMode.lighten,
      'luminosity' => BlendMode.luminosity,
      _ => null,
    },
  );

  double? _double(dynamic v) => v == null ? null : double.tryParse(v.toString());
}
