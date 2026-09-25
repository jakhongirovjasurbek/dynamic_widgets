import 'package:dynamic_widgets/colors/primitive_colors.dart';
import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:dynamic_widgets/extensions/context_extension.dart';
import 'package:flutter/material.dart';

final class JsonWidget$Container extends JsonWidget {
  JsonWidget$Container(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) {
    return Container(
      width: parseDouble(json['width']),
      height: parseDouble(json['height']),
      padding: parseEdgeInsets(json['padding']),
      margin: parseEdgeInsets(json['margin']),
      alignment: _alignment(json['alignment']),
      decoration: _decoration(json),
      color: json.containsKey('decoration')
          ? null
          : context.colors.getColorFromName(json['color'], parseDouble(json['colorOpacity'])),
      child: childOrNull(json['child'], arguments: arguments),
    );
  }

  Alignment? _alignment(dynamic value) {
    if (value == null) return null;

    switch (value) {
      case 'center':
        return Alignment.center;
      case 'topLeft':
        return Alignment.topLeft;
      case 'topRight':
        return Alignment.topRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomRight':
        return Alignment.bottomRight;
    }
    return Alignment.center;
  }

  BoxDecoration? _decoration(Map<String, dynamic> json) {
    if (!json.containsKey('decoration')) return null;

    final dec = json['decoration'];

    if (dec is! Map<String, dynamic>) return null;

    return BoxDecoration(
      color: context.colors.getColorFromName(dec['color'], parseDouble(dec['colorOpacity'])),
      borderRadius: dec['borderRadius'] != null
          ? BorderRadius.circular(parseDouble(dec['borderRadius']) ?? 0)
          : null,
      border: dec['border'] is Map<String, dynamic>
          ? Border.all(
              color:
                  context.colors.getColorFromName(
                    dec['border']['color'],
                    parseDouble(dec['border']['colorOpacity']),
                  ) ??
                  Colors.black,
              width: parseDouble(dec['border']['width']) ?? 1.0,
            )
          : null,
      boxShadow: dec['boxShadow'] is List
          ? (dec['boxShadow'] as List)
                .whereType<Map<String, dynamic>>()
                .map(
                  (m) => BoxShadow(
                    color:
                        context.colors.getColorFromName(m['color'], parseDouble(m['colorOpacity'])) ??
                        Colors.black,
                    blurRadius: parseDouble(m['blur']) ?? 0,
                    spreadRadius: parseDouble(m['spread']) ?? 0,
                    offset: Offset(parseDouble(m['dx']) ?? 0, parseDouble(m['dy']) ?? 0),
                  ),
                )
                .toList()
          : null,
    );
  }
}
