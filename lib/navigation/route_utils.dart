import 'dart:math';

import 'package:collection/collection.dart';
import 'package:router_app/navigation/route_path.dart';

import 'custom_route_config.dart';

class RouteUtils {
  static List<RoutePath> pathToRoutes(String? path, Routes config) {
    final segments = Uri.tryParse(path ?? '')?.pathSegments ?? [];
    final initialRoute = config.stack.firstWhereOrNull((r) => r.path == '/');
    final List<RoutePath> routes = initialRoute != null ? [initialRoute] : [];
    for (var segment in segments) {
      final route = config.stack.firstWhereOrNull((e) => e.path == '/$segment');
      if (route != null) {
        routes.add(route);
      }
    }
    if (routes.isNotEmpty) {
      return routes;
    }
    return [routeNotFoundPath];
  }

  static Routes uriToRoutes(String? path, List<RoutePath> routes) {
    assert(routes.isNotEmpty, 'route config should be not empty');

    final branchRoutes = routes.where((c) => c.children.isNotEmpty).toList();
    final rootRoutes = routes.where((c) => c.children.isEmpty).toList();

    final uri = Uri.tryParse(path ?? '');
    final segments = uri?.pathSegments ?? [];
    final rootPath = segments.isNotEmpty ? '/${segments[0]}' : null;

    List<RoutePath> rootStack = [];
    int tabIndex = 0;

    final rootRoute = rootRoutes
        .firstWhereOrNull((c) => c.path == uri?.path)
        ?.copyWith(queryParams: uri?.queryParameters);

    // вложенный стек
    if (rootPath != null && segments.length > 1) {
      for (var i = 0; i < branchRoutes.length; i++) {
        var route = branchRoutes[i];
        final childStack = _clearNestedStack(route.children);
        if (route.path.startsWith(rootPath)) {
          final childRoute = route.children
              .firstWhereOrNull((c) => c.path == '/${segments[1]}');
          if (childRoute != null) {
            final childRouteIndex = route.children.indexOf(childRoute);
            if (childRouteIndex > 0) {
              childStack
                  .add(childRoute.copyWith(queryParams: uri?.queryParameters));
            }
          }
          tabIndex = i;
        }
        route = route.copyWith(children: childStack);
        rootStack.add(route);
      }
      final stack = rootRoute == null ? rootStack : [...rootStack, rootRoute];
      return Routes(stack, tabIndex);
    }

    if (branchRoutes.isNotEmpty) {
      final branchStack = _clearRootRoutesStack(branchRoutes);

      final children = branchStack[tabIndex].children;
      if (children.isNotEmpty) {
        children[0] = children[0].copyWith(queryParams: uri?.queryParameters);
      }

      final stack =
          rootRoute == null ? branchStack : [...branchStack, rootRoute];
      return Routes(stack, tabIndex);
    }
    // if (routes.isNotEmpty) {
    //   return Routes(routes, tabIndex);
    // }
    return Routes([routeNotFoundPath]);
  }

  static Routes pushPathToStack(String? path, List<RoutePath> routes,
      List<RoutePath> stack, int selectedIndex) {
    final uri = Uri.tryParse(path ?? '');
    final segments = uri?.pathSegments ?? [];

    final rootPath = segments.isNotEmpty ? '/${segments[0]}' : null;

    final rootRoute = routes.firstWhereOrNull((e) => e.path == uri?.path);

    // Добавляем роут в рутовый стек
    if (rootRoute != null && rootRoute.children.isEmpty) {
      return Routes(
          [...stack, rootRoute.copyWith(queryParams: uri?.queryParameters)],
          selectedIndex);
    }

    // Добавляем роут во вложенный стек
    if (rootPath != null && segments.length > 1) {
      final targetRoute = stack.firstWhereOrNull((e) => e.path == rootPath);
      if (targetRoute != null) {
        final index = stack.indexOf(targetRoute);
        final updatedNestedStack =
            _updateNestedStack(routes, targetRoute, '/${segments[1]}', uri);     

        final targetStack = [...stack];
        targetStack[index] =
            targetStack[index].copyWith(children: updatedNestedStack);
        return Routes(targetStack, index);
      }
    }

    return Routes([]);
  }

  static List<RoutePath> _clearRootRoutesStack(List<RoutePath> routes) {
    return routes
        .map((route) =>
            route.copyWith(children: _clearNestedStack(route.children)))
        .toList();
  }

  static List<RoutePath> _clearNestedStack(List<RoutePath> stack) {
    return stack.isNotEmpty ? [stack[0]] : [];
  }

  static RoutePath? _findNestedRoute(List<RoutePath> routes, String path) {
    RoutePath? routePath;
    for (var route in routes) {
      final result = route.children.firstWhereOrNull((e) => e.path == path);
      if (result != null) {
        routePath = result;
        break;
      }
    }
    return routePath;
  }

  static List<RoutePath> _updateNestedStack(
      List<RoutePath> routes, RoutePath stack, String path, Uri? uri) {
    final nestedRoute = stack.children.firstWhereOrNull((c) => c.path == path);
    if (nestedRoute != null) {
      final index = stack.children.indexOf(nestedRoute);
      final oldQuery = nestedRoute.queryString;
      final newRoute = nestedRoute.copyWith(queryParams: uri?.queryParameters);
      final newQuery = newRoute.queryString;
      if (oldQuery != newQuery) {
        return [...stack.children, newRoute];
      }
      final newStack =
          stack.children.sublist(0, min(index + 1, stack.children.length));
      newStack[index] =
          newStack[index].copyWith(queryParams: uri?.queryParameters);
      return newStack;
    } else {
      final route = _findNestedRoute(routes, path);
      return route != null
          ? [
              ...stack.children,
              route.copyWith(queryParams: uri?.queryParameters)
            ]
          : [...stack.children];
    }
  }
}
