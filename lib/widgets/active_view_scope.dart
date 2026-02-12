import 'package:flutter/material.dart';
import '../models/types.dart';

/// Exposes the current active nav view so child views (e.g. RealTimeView) can
/// skip setState when they are no longer active (e.g. during transition fade).
class ActiveViewScope extends InheritedWidget {
  const ActiveViewScope({
    super.key,
    required this.activeView,
    required super.child,
  });

  final ViewType activeView;

  /// Use in build() or when you need rebuilds when activeView changes.
  static ActiveViewScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ActiveViewScope>();
  }

  /// Use in initState/async callbacks — does not register dependency (safe before initState done).
  static ActiveViewScope? find(BuildContext context) {
    return context.findAncestorWidgetOfExactType<ActiveViewScope>();
  }

  @override
  bool updateShouldNotify(ActiveViewScope oldWidget) =>
      oldWidget.activeView != activeView;
}
