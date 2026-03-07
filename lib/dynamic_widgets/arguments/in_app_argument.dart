
import 'package:flutter/material.dart';

final class InAppArgument {
  const InAppArgument({required this.widgetId, required this.child});

  final String widgetId;
  final Widget child;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppArgument &&
          runtimeType == other.runtimeType &&
          widgetId == other.widgetId &&
          child == other.child;

  @override
  int get hashCode => Object.hash(widgetId, child);

  @override
  String toString() => 'InAppArgument{widgetId: $widgetId, child: $child}';
}
