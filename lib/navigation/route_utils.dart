import 'dart:math';

import 'package:collection/collection.dart';
import 'package:router_app/navigation/route_path.dart';

import 'custom_route_config.dart';

class RouteParseUtils {
  //Возвращает конфигурацию для навигации. Вызывается системой
  static NavigationStack restoreRouteStack(
      String? location, List<RoutePath> routes) {
    assert(routes.isNotEmpty, 'route config should be not empty');

    final branchRoutes = routes.where((c) => c.children.isNotEmpty).toList();
    final rootRoutes = routes.where((c) => c.children.isEmpty).toList();

    final uri = Uri.tryParse(location ?? '');
    final segments = uri?.pathSegments ?? [];
    final rootPath = segments.isNotEmpty ? '/${segments[0]}' : null;

    List<RoutePath> rootStack = [];
    int currentIndex = 0;

    final rootRoute = rootRoutes
        .firstWhereOrNull((c) => c.path == uri?.path)
        ?.copyWith(queryParams: uri?.queryParameters);

    // вложенный стек
    if (rootPath != null && segments.length > 1) {
      for (var i = 0; i < branchRoutes.length; i++) {
        var route = branchRoutes[i];
        final childStack = _clearNestedStack(route.children);
        if (route.path.startsWith(rootPath)) {
          final nestedPath = _getNestedPath(uri?.path ?? '');
          final childRoute = route.children.firstWhereOrNull(
              (c) => c.path == nestedPath);        
          if (childRoute != null) {
            final childRouteIndex = route.children.indexOf(childRoute);
            if (childRouteIndex > 0) {
              childStack
                  .add(childRoute.copyWith(queryParams: uri?.queryParameters));
            }
          }
          currentIndex = i;
        }
        route = route.copyWith(children: childStack);
        rootStack.add(route);
      }
      final stack = rootRoute == null ? rootStack : [...rootStack, rootRoute];
      return NavigationStack(stack,
          currentIndex: currentIndex, currentLocation: location ?? '');
    }

    if (branchRoutes.isNotEmpty) {
      final branchStack = _clearRootRoutesStack(branchRoutes);

      final children = branchStack[currentIndex].children;
      if (children.isNotEmpty) {
        children[0] = children[0].copyWith(queryParams: uri?.queryParameters);
      }

      final stack =
          rootRoute == null ? branchStack : [...branchStack, rootRoute];
      return NavigationStack(stack,
          currentIndex: currentIndex, currentLocation: location ?? '');
    }
    // if (routes.isNotEmpty) {
    //   return Routes(routes, tabIndex);
    // }
    return NavigationStack([routeNotFoundPath]);
  }

  //Возвращает конфигурацию для навигации. Вызывается приложением
  static NavigationStack pushRouteToStack(
      String? routePath, List<RoutePath> routeList, NavigationStack stack) {
    final uri = Uri.tryParse(routePath ?? '');
    final segments = uri?.pathSegments ?? [];

    final rootPath = segments.isNotEmpty ? '/${segments[0]}' : null;
    final rootRoute = routeList.firstWhereOrNull((e) => e.path == uri?.path);
    final routes = stack.routes;

    // Добавляем роут в рутовый стек
    if (rootRoute != null && rootRoute.children.isEmpty) {
      final rootStack = _updateStack(
          routeList: routeList, stack: routes, isRootStack: true, uri: uri);

      return stack.copyWith(
          routes: rootStack, currentLocation: rootStack.last.path);
    }

    // Добавляем роут во вложенный стек
    if (rootPath != null && segments.length > 1) {
      final targetRoute = routes.firstWhereOrNull((e) => e.path == rootPath);
      if (targetRoute != null) {
        final index = routes.indexOf(targetRoute);
        final updatedNestedStack = _updateStack(
            routeList: routeList, stack: targetRoute.children, uri: uri);

        final targetStack = [...routes];
        targetStack[index] =
            targetStack[index].copyWith(children: updatedNestedStack);
        return NavigationStack(targetStack,
            currentIndex: index, currentLocation: routePath ?? '');
      }
    }

    return NavigationStack([]);
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

  // Поиск по роута в заданной конфигурации.
  static RoutePath? _searchRoute(List<RoutePath> routeList, String path,
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

  // Возвращает обновленный стек для вложенных роутов.
  // Если роут найден в стеке и параметры совпадают обрезает стек(возвращает стек в котором роут последний)
  // Если роут найден в стеке и параметры не совпадают то добавляет роут в стек как новый роут
  // Если роут не найден в стеке то он извелкается из заданной конфигурации и добавляется в стек
  static List<RoutePath> _updateStack(
      {required List<RoutePath> routeList,
      required List<RoutePath> stack,
      bool isRootStack = false,
      Uri? uri}) {
    final fullPath = uri?.path ?? '';
    final path = isRootStack ? fullPath : _getNestedPath(fullPath);
    final curentRoute = stack.lastWhereOrNull((c) => c.path == path);
    if (curentRoute != null) {
      final targetRoute =
          curentRoute.copyWith(queryParams: uri?.queryParameters);
      return _pushOrShrinkStack(
          stack: stack,
          currentRoute: curentRoute,
          targetRoute: targetRoute,
          uri: uri);
    } else {
      final route = _searchRoute(routeList, path, isRootStack);
      return route != null
          ? [...stack, route.copyWith(queryParams: uri?.queryParameters)]
          : [...stack];
    }
  }

  static String _getNestedPath(String path) {
    final nestedSegments = path.split('/').sublist(2);
    return nestedSegments.isNotEmpty ? '/${nestedSegments.join('/')}' : '';
  }

  // Сравнивает текущий роут и новый роут и возвращает обновленный стек
  // Если роут найден в стеке и параметры совпадают то обрезает стек(возвращает стек в котором роут последний)
  // Если роут найден в стеке и параметры не совпадают то добавляет роут в стек как новый роут
  static List<RoutePath> _pushOrShrinkStack(
      {required List<RoutePath> stack,
      required RoutePath currentRoute,
      required RoutePath targetRoute,
      required Uri? uri}) {
    if (currentRoute != targetRoute) {
      return [...stack, targetRoute];
    }
    final index = stack.indexOf(targetRoute);
    final subRoutes = stack.sublist(0, min(index + 1, stack.length));
    subRoutes[index] =
        subRoutes[index].copyWith(queryParams: uri?.queryParameters);
    return subRoutes;
  }
}
