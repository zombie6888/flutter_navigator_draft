import 'package:flutter/widgets.dart';

import 'route_path.dart';

class RouteData extends InheritedWidget {
   const RouteData({
    super.key,
    required this.routePath,
    required super.child,
  });

  final RoutePath routePath;

  static RouteData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RouteData>();
  }

  static RoutePath of(BuildContext context) {
    final RouteData? result = maybeOf(context);
    assert(result != null, 'No FrogColor found in context');
    return result!.routePath;
  }

  @override
  bool updateShouldNotify(RouteData oldWidget) => false;
}