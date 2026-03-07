import 'package:dynamic_widgets/colors/dark_colors.dart';
import 'package:dynamic_widgets/colors/light_colors.dart';
import 'package:dynamic_widgets/colors/primitive_colors.dart';
import 'package:flutter/material.dart';

extension ColorExtension on BuildContext {
  PrimitiveColors get colors {
    if (Theme.of(this).colorScheme.brightness == Brightness.light) {
      return LightModeColors();
    } else {
      return DarkModeColors();
    }
  }
}
