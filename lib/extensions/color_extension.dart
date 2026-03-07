import 'dart:ui';

extension ColorPaintingExtension on Color {
  Color colorOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withAlpha((255.0 * opacity).round());
  }
}
