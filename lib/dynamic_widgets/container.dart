import 'package:dynamic_widgets/colors/primitive_colors.dart';
import 'package:dynamic_widgets/dynamic_widgets/arguments/in_app_argument.dart';
import 'package:dynamic_widgets/dynamic_widgets/json_widget.dart';
import 'package:dynamic_widgets/extensions/context_extension.dart';
import 'package:flutter/material.dart';

final class JsonWidget$Container extends JsonWidget {
  JsonWidget$Container(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) {
    final childJson = json['child'];

    return Container(
      width: _double(json['width']),
      height: _double(json['height']),
      padding: _edgeInsets(json['padding']),
      margin: _edgeInsets(json['margin']),
      alignment: _alignment(json['alignment']),
      decoration: _decoration(json),
      color: json.containsKey('decoration')
          ? null
          : context.colors.getColorFromName(json['color'], _double(json['colorOpacity'])),
      child: childJson is Map<String, dynamic>
          ? JsonWidget.fromType(context: context, json: childJson, arguments: arguments)
          : null,
    );
  }

  // --------------------------
  // Parsing helpers
  // --------------------------

  double? _double(dynamic v) => v == null ? null : double.tryParse(v.toString());

  EdgeInsets? _edgeInsets(dynamic v) {
    if (v == null) return null;

    if (v is num) {
      return EdgeInsets.all(v.toDouble());
    }

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
      color: context.colors.getColorFromName(dec['color'], _double(dec['colorOpacity'])),
      borderRadius: dec['borderRadius'] != null
          ? BorderRadius.circular(_double(dec['borderRadius']) ?? 0)
          : null,
      border: dec['border'] is Map<String, dynamic>
          ? Border.all(
              color:
                  context.colors.getColorFromName(
                    dec['border']['color'],
                    _double(dec['border']['colorOpacity']),
                  ) ??
                  Colors.black,
              width: _double(dec['border']['width']) ?? 1.0,
            )
          : null,
      boxShadow: dec['boxShadow'] is List
          ? (dec['boxShadow'] as List)
                .whereType<Map<String, dynamic>>()
                .map(
                  (m) => BoxShadow(
                    color:
                        context.colors.getColorFromName(m['color'], _double(m['colorOpacity'])) ??
                        Colors.black,
                    blurRadius: _double(m['blur']) ?? 0,
                    spreadRadius: _double(m['spread']) ?? 0,
                    offset: Offset(_double(m['dx']) ?? 0, _double(m['dy']) ?? 0),
                  ),
                )
                .toList()
          : null,
    );
  }
}
