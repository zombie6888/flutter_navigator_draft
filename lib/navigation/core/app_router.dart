import 'package:flutter/widgets.dart';

import 'custom_route_delegate.dart';
import 'navigation_observer.dart';
import 'route_path.dart';

class AppRouter extends InheritedWidget {
  const AppRouter({
    super.key,
    required this.routePath,
    required this.routerDelegate,
    this.navigatorKey,
    required super.child,
  });

  final RoutePath routePath;
  final GlobalKey<NavigatorState>? navigatorKey;
  final CustomRouteDelegate routerDelegate;

  Stream<LocationUpdateData>? get locationUpdates {
    if (routerDelegate.observer is LocationStreamController) {
      return (routerDelegate.observer as LocationStreamController).stream;
    }
    return null;
  }

  pushNamed(String path) {
    routerDelegate.pushNamed(path);
  }

  pop() {
    final navigator = navigatorKey?.currentState;
    assert(navigator != null, 'No navigator found');
    navigator?.pop();
  }

  static AppRouter? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppRouter>();
  }

  static AppRouter of(BuildContext context) {
    final AppRouter? result = maybeOf(context);
    assert(result != null, 'No FrogColor found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppRouter oldWidget) => false;
}
