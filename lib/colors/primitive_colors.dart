import 'dart:ui';

import 'package:dynamic_widgets/extensions/color_extension.dart';

abstract class PrimitiveColors {
  const PrimitiveColors();

  Color get primary;

  Color get onPrimary;

  Color get primaryContainer;

  Color get onPrimaryContainer;

  Color get secondary;

  Color get onSecondary;

  Color get secondaryContainer;

  Color get onSecondaryContainer;

  Color get tertiary;

  Color get onTertiary;

  Color get tertiaryContainer;

  Color get onTertiaryContainer;

  Color get error;

  Color get onError;

  Color get errorContainer;

  Color get onErrorContainer;

  Color get surfaceDim;

  Color get surfaceContainerLowest;

  Color get onSurface;

  Color get surfaceContainerLow;

  Color get surface;

  Color get surfaceContainer;

  Color get onSurfaceVariant;

  Color get outline;

  Color get surfaceBright;

  Color get surfaceContainerHigh;

  Color get surfaceContainerHighest;

  Color get outlineVariant;

  Color get primaryFixed;

  Color get primaryFixedDim;

  Color get onPrimaryFixed;

  Color get onPrimaryFixedVariant;

  Color get secondaryFixed;

  Color get secondaryFixedDim;

  Color get onSecondaryFixed;

  Color get onSecondaryFixedVariant;

  Color get tertiaryFixed;

  Color get tertiaryFixedDim;

  Color get onTertiaryFixed;

  Color get onTertiaryFixedVariant;

  Color get inverseSurface;

  Color get inverseOnSurface;

  Color get inversePrimary;

  Color get scrim;

  Color get shadow;

  Color get surfaceTint;

  Color get success;

  Color get errorText;

  Color get waiting;

  Color get walletGlass;
}

extension PrimitiveColorExtension on PrimitiveColors {
  Color? getColorFromName(String? colorName, double? opacity) => switch (colorName) {
    'primary' => primary.colorOpacity(opacity ?? 1),
    'onPrimary' => onPrimary.colorOpacity(opacity ?? 1),
    'primaryContainer' => primaryContainer.colorOpacity(opacity ?? 1),
    'onPrimaryContainer' => onPrimaryContainer.colorOpacity(opacity ?? 1),
    'secondary' => secondary.colorOpacity(opacity ?? 1),
    'onSecondary' => onSecondary.colorOpacity(opacity ?? 1),
    'secondaryContainer' => secondaryContainer.colorOpacity(opacity ?? 1),
    'onSecondaryContainer' => onSecondaryContainer.colorOpacity(opacity ?? 1),
    'tertiary' => tertiary.colorOpacity(opacity ?? 1),
    'onTertiary' => onTertiary.colorOpacity(opacity ?? 1),
    'tertiaryContainer' => tertiaryContainer.colorOpacity(opacity ?? 1),
    'onTertiaryContainer' => onTertiaryContainer.colorOpacity(opacity ?? 1),
    'error' => error.colorOpacity(opacity ?? 1),
    'onError' => onError.colorOpacity(opacity ?? 1),
    'errorContainer' => errorContainer.colorOpacity(opacity ?? 1),
    'onErrorContainer' => onErrorContainer.colorOpacity(opacity ?? 1),
    'surfaceDim' => surfaceDim.colorOpacity(opacity ?? 1),
    'surfaceContainerLowest' => surfaceContainerLowest.colorOpacity(opacity ?? 1),
    'onSurface' => onSurface.colorOpacity(opacity ?? 1),
    'surfaceContainerLow' => surfaceContainerLow.colorOpacity(opacity ?? 1),
    'surface' => surface.colorOpacity(opacity ?? 1),
    'surfaceContainer' => surfaceContainer.colorOpacity(opacity ?? 1),
    'onSurfaceVariant' => onSurfaceVariant.colorOpacity(opacity ?? 1),
    'outline' => outline.colorOpacity(opacity ?? 1),
    'surfaceBright' => surfaceBright.colorOpacity(opacity ?? 1),
    'surfaceContainerHigh' => surfaceContainerHigh.colorOpacity(opacity ?? 1),
    'surfaceContainerHighest' => surfaceContainerHighest.colorOpacity(opacity ?? 1),
    'outlineVariant' => outlineVariant.colorOpacity(opacity ?? 1),
    'primaryFixed' => primaryFixed.colorOpacity(opacity ?? 1),
    'primaryFixedDim' => primaryFixedDim.colorOpacity(opacity ?? 1),
    'onPrimaryFixed' => onPrimaryFixed.colorOpacity(opacity ?? 1),
    'onPrimaryFixedVariant' => onPrimaryFixedVariant.colorOpacity(opacity ?? 1),
    'secondaryFixed' => secondaryFixed.colorOpacity(opacity ?? 1),
    'secondaryFixedDim' => secondaryFixedDim.colorOpacity(opacity ?? 1),
    'onSecondaryFixed' => onSecondaryFixed.colorOpacity(opacity ?? 1),
    'onSecondaryFixedVariant' => onSecondaryFixedVariant.colorOpacity(opacity ?? 1),
    'tertiaryFixed' => tertiaryFixed.colorOpacity(opacity ?? 1),
    'tertiaryFixedDim' => tertiaryFixedDim.colorOpacity(opacity ?? 1),
    'onTertiaryFixed' => onTertiaryFixed.colorOpacity(opacity ?? 1),
    'onTertiaryFixedVariant' => onTertiaryFixedVariant.colorOpacity(opacity ?? 1),
    'inverseSurface' => inverseSurface.colorOpacity(opacity ?? 1),
    'inverseOnSurface' => inverseOnSurface.colorOpacity(opacity ?? 1),
    'inversePrimary' => inversePrimary.colorOpacity(opacity ?? 1),
    'scrim' => scrim.colorOpacity(opacity ?? 1),
    'shadow' => shadow.colorOpacity(opacity ?? 1),
    'surfaceTint' => surfaceTint.colorOpacity(opacity ?? 1),
    'success' => success.colorOpacity(opacity ?? 1),
    'errorText' => errorText.colorOpacity(opacity ?? 1),
    'waiting' => waiting.colorOpacity(opacity ?? 1),
    _ => null,
  };
}
