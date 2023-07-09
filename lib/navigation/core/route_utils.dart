import 'dart:math';

import 'package:collection/collection.dart';
import 'package:router_app/navigation/core/route_path.dart';

import 'navigation_stack.dart';

/// Utility class, which is using to parse route path [uri] to navigation stack
class RouteParseUtils {
  late Uri _uri;
  RouteParseUtils(String? path) {
    assert(path != null, 'not a valid path!');
    _uri = Uri.tryParse(path!) ?? Uri();
  }

  String? get rootPath =>
      _uri.pathSegments.isNotEmpty ? '/${_uri.pathSegments[0]}' : null;

  /// Returns updated configaration [NavigationStack]
  ///
  /// Takes [routes] from [RouteInformationParser]
  /// and return updated navigation stack. Called by platform.
  NavigationStack restoreRouteStack(List<RoutePath> routes) {
    assert(routes.isNotEmpty, 'route config should be not empty');

    final branchRoutes = routes.where((c) => c.children.isNotEmpty).toList();
    final rootRoutes = routes.where((c) => c.children.isEmpty).toList();

    List<RoutePath> rootStack = [];
    int currentIndex = 0;

    final rootRoute = rootRoutes
        .firstWhereOrNull((c) => c.path == _uri.path)
        ?.copyWith(queryParams: _uri.queryParameters);

    // nested stack
    if (rootPath != null && _uri.pathSegments.length > 1) {
      for (var i = 0; i < branchRoutes.length; i++) {
        var route = branchRoutes[i];
        final childStack = _resetStack(route.children);
        if (route.path.startsWith(rootPath ?? '')) {
          final nestedPath = _getNestedPath(_uri.path);
          final childRoute =
              route.children.firstWhereOrNull((c) => c.path == nestedPath);
          if (childRoute != null) {
            final childRouteIndex = route.children.indexOf(childRoute);
            if (childRouteIndex > 0) {
              childStack
                  .add(childRoute.copyWith(queryParams: _uri.queryParameters));
            }
          }
          currentIndex = i;
        }
        route = route.copyWith(children: childStack);
        rootStack.add(route);
      }
      final stack = rootRoute == null ? rootStack : [...rootStack, rootRoute];
      return NavigationStack(stack,
          currentIndex: currentIndex, currentLocation: _uri.path);
    }

    // root stack
    if (branchRoutes.isNotEmpty) {
      final branchStack = _clearRootRoutesStack(branchRoutes);

      final currentBranch = branchStack[currentIndex];
      final children = [...currentBranch.children];
      if (children.isNotEmpty) {
        children.first =
            children.first.copyWith(queryParams: _uri.queryParameters);
      }
      branchStack[currentIndex] = currentBranch.copyWith(children: children);

      final stack =
          rootRoute == null ? branchStack : [...branchStack, rootRoute];
      return NavigationStack(stack,
          currentIndex: currentIndex, currentLocation: _uri.path);
    }
    // if (routes.isNotEmpty) {
    //   return Routes(routes, tabIndex);
    // }
    return NavigationStack([routeNotFoundPath]);
  }

  /// Returns updated configaration [NavigationStack]
  ///
  /// Takes [routeList] and current [stack] from [RouterDelegate]
  /// and return updated navigation stack. Called by [CustomRouteDelegate.pushNamed].
  NavigationStack pushRouteToStack(
      List<RoutePath> routeList, NavigationStack stack) {
    // final uri = Uri.tryParse(routePath ?? '');
    // final segments = uri?.pathSegments ?? [];

    // final rootPath = segments.isNotEmpty ? '/${segments[0]}' : null;
    final rootRoute = routeList.firstWhereOrNull((e) => e.path == _uri.path);
    final routes = stack.routes;

    // add route to root stack
    if (rootRoute != null && rootRoute.children.isEmpty) {
      final rootStack =
          _updateStack(routeList: routeList, stack: routes, isRootStack: true);

      return stack.copyWith(
          routes: rootStack, currentLocation: rootStack.last.path);
    }

    // add route to nested stack
    if (rootPath != null && _uri.pathSegments.length > 1) {
      final targetRoute = routes.firstWhereOrNull((e) => e.path == rootPath);
      if (targetRoute != null) {
        final index = routes.indexOf(targetRoute);
        final updatedNestedStack =
            _updateStack(routeList: routeList, stack: targetRoute.children);

        final targetStack = [...routes];
        targetStack[index] =
            targetStack[index].copyWith(children: updatedNestedStack);
        return NavigationStack(targetStack,
            currentIndex: index, currentLocation: _uri.path);
      }
    }

    return NavigationStack([]);
  }

  /// Returns routes whith only first route in nested stack
  ///
  /// Fro example for routes:
  /// tab1
  ///   --page1
  ///   --page2
  ///   ...
  /// tab2
  ///   --page3
  ///   --page4
  ///   --page5
  ///   ...
  /// result is:
  /// tab1
  ///   --page1   
  /// tab2
  ///   --page3
  List<RoutePath> _clearRootRoutesStack(List<RoutePath> routes) {
    return [
      ...routes.map((route) =>
          route.copyWith(children: _resetStack(route.children)))
    ];
  }

  /// Return routes whith only first route in stack
  List<RoutePath> _resetStack(List<RoutePath> stack) {
    return stack.isNotEmpty ? [stack.first] : [];
  }

  /// Search route in [routeList] configuration
  RoutePath? _searchRoute(List<RoutePath> routeList, String path,
      [bool searchInRootRoutes = false]) {
    if (searchInRootRoutes) {
      return routeList.lastWhereOrNull((e) => e.path == path);
    }
    RoutePath? routePath;
    for (var route in routeList) {
      final result = route.children.lastWhereOrNull((e) => e.path == path);
      if (result != null) {
        routePath = result;
        break;
      }
    }
    return routePath;
  }

  /// Returns updated route list for nested routes depending on [_uri.path]
  /// and [_uri.queryParameters].

  /// if route was found in [stack] and it has the same query parameters,
  /// then crop stack (return stack, where route is last).
  ///
  /// if route was found but query parameters are different,
  /// then adds route to stack as a new route.
  ///
  /// if route wasn't found in [stack], it will try to search route in [routeList]
  /// and adds it to stack as a new route in case of success
  ///
  /// for example for stack:
  ///   [page1, page2?q=1, page3]
  /// you push "page2?q=2"
  /// updated stack will be: [page1, page2?q=1, page3, page2?q=2]
  /// or you push "page2?q=1"
  /// updated stack will be: [page1, page2?q=1]
  List<RoutePath> _updateStack({
    required List<RoutePath> routeList,
    required List<RoutePath> stack,
    bool isRootStack = false,
  }) {
    final fullPath = _uri.path;
    final path = isRootStack ? fullPath : _getNestedPath(fullPath);
    final currentRoute = stack.lastWhereOrNull((c) => c.path == path);
    if (currentRoute != null) {
      final targetRoute =
          currentRoute.copyWith(queryParams: _uri.queryParameters);
      if (currentRoute != targetRoute) {
        return [...stack, targetRoute];
      }
      return _cropStack(
        stack: stack,
        currentRoute: currentRoute,
        targetRoute: targetRoute,
      );
    } else {
      final route = _searchRoute(routeList, path, isRootStack);
      return route != null
          ? [...stack, route.copyWith(queryParams: _uri.queryParameters)]
          : [...stack];
    }
  }

  /// Returns nested path for subroutes
  String _getNestedPath(String path) {
    final nestedSegments = path.split('/').sublist(2);
    return nestedSegments.isNotEmpty ? '/${nestedSegments.join('/')}' : '';
  }

  /// Returns stack, where route is last
  List<RoutePath> _cropStack({
    required List<RoutePath> stack,
    required RoutePath currentRoute,
    required RoutePath targetRoute,
  }) {
    final index = stack.indexOf(targetRoute);
    final subRoutes = stack.sublist(0, min(index + 1, stack.length));
    subRoutes[index] =
        subRoutes[index].copyWith(queryParams: _uri.queryParameters);
    return subRoutes;
  }
}
