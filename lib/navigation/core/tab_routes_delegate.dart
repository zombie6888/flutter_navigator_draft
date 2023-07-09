import 'package:flutter/material.dart';
import 'package:router_app/navigation/core/keep_alive_widget.dart';
import 'package:router_app/navigation/core/route_path.dart';
import 'package:router_app/navigation/core/route_utils.dart';
import 'package:router_app/navigation/core/tab_routes_config.dart';
import 'package:router_app/navigation/transitions/platform_page_factory.dart';

import 'app_router.dart';
import 'custom_route_delegate.dart';
import 'navigation_stack.dart';
import 'tab_stack_builder.dart';

typedef TabPageBuilder = Widget Function(BuildContext context,
    Iterable<RoutePath> tabRoutes, TabBarView view, TabController controller);

/// Router delagate for tabs navigation.
/// 
/// This class handle [NavigationStack] updates
/// from predefined route configuration [routes] and uses [tabPageBuider]
/// for showing tab navigation pages. It contains root [Navigator]
/// and nested [Navigator] list. When nested route requested it will push/pop pages
/// to nested navigator. When root route requested,
/// it will updates pages in root navigator.
/// It supports only two-level navigation, see [RoutePath]
class TabRoutesDelegate extends RouterDelegate<NavigationStack>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin
    implements CustomRouteDelegate {
  TabRoutesDelegate(List<RoutePath> routes, this.tabPageBuider)
      : _routes = List.unmodifiable(routes),
        _rootNavigatorKey = GlobalKey<NavigatorState>();


  /// Widget builder for tabs page. Mostly scaffold with bootomTabBar.
  final TabPageBuilder tabPageBuider;

  
  /// Uses for root navigator access
  final GlobalKey<NavigatorState> _rootNavigatorKey;


  /// [NavigationStack] keeps all data which is neccessary for [currentConfiguration].
  ///
  /// As opposite to [_routes], we can modify [_stack.routes] list.
  NavigationStack _stack = NavigationStack([]);


  /// Route configaration which could be passed to [TabRoutesConfig]
  /// 
  /// This is predefined routes and it shouldn't be changed.
  /// Route parse utilities will pick routes from [_routes] list and update 
  /// [NavigationStack] accordingly. As opposite to [_stack.routes],
  /// this list is unmodifiable.
  final List<RoutePath> _routes;


  /// Whether page was opened from deep link
  bool _fromDeepLink = true;

  
  /// Index of previous opened tab
  int _previousIndex = 0;

  /// Returns pages wrapped with nested [Navigator]
  Widget getNestedNavigator(int index, BuildContext context) {
    final rootRoute = _stack.routes[index];
    final nestedPages = rootRoute.children
        .map(
          (route) => PlatformPageFactory.getPage(
              child: _createPage(context, route, rootRoute.navigatorKey)),
        )
        .toList();

    if (nestedPages.isEmpty) {
      return routeNotFoundPath.widget!;
    }

    return Navigator(
        key: _stack.routes[index].navigatorKey,
        pages: nestedPages,
        onGenerateRoute: (settings) =>
            MaterialPageRoute(builder: (_) => Container()),
        onUnknownRoute: (settings) =>
            MaterialPageRoute(builder: (_) => Container()),
        onPopPage: _onPopNestedPage);
  }

  /// See [RouterDelegate.navigatorKey]
  @override
  GlobalKey<NavigatorState>? get navigatorKey => GlobalKey();

  /// Current navigation config. 
  @override
  NavigationStack? get currentConfiguration => _stack;
  
  /// This will update navigation configration.
  /// 
  /// [_stack] could be updated either, by [pushNamed] function 
  /// or by platform. For example if you come from deep link.
  /// See [RouterDelegate.setNewRoutePath]
  @override
  Future<void> setNewRoutePath(NavigationStack configuration) async {
    _previousIndex = _stack.currentIndex;
    _stack = configuration;
    notifyListeners();
  }

  /// Push page to navigation stack [_stack]
  ///
  /// It will be called when you run
  /// ```dart
  /// AppRouter.of(context).pushNamed('page');
  /// ```
  @override
  pushNamed(String path) {
    _fromDeepLink = false;
    final upadatedStack =
        RouteParseUtils(path).pushRouteToStack(_routes, _stack);
    setNewRoutePath(upadatedStack);
  }

  @override
  Widget build(BuildContext context) {
    final routes = _stack.routes;
    if (routes.isEmpty) {
      return routeNotFoundPath.widget!;
    }

    final pages = routes.where((e) => e.children.isEmpty).map(
          (route) =>
              PlatformPageFactory.getPage(child: _createPage(context, route)),
        );

    final tabRoutes = routes.where((e) => e.children.isNotEmpty);

    return Navigator(
        key: _rootNavigatorKey,
        pages: [
          MaterialPage(
            child: TabStackBuilder(
                index: _stack.currentIndex,
                tabIndexUpdateHandler: _tabIndexUpdateHandler,
                tabsLenght: tabRoutes.length,
                builder: (context, controller) {
                  final view = TabBarView(
                    controller: controller,
                    children: [
                      for (var i = 0; i < tabRoutes.length; i++)
                        KeepAliveWidget(
                            key: ValueKey('tab_stack_${i.toString()}'),
                            child: getNestedNavigator(i, context)),
                    ],
                  );
                  return tabPageBuider(context, tabRoutes, view, controller);
                }),
          ),
          ...pages
        ],
        onGenerateRoute: (settings) =>
            MaterialPageRoute(builder: (_) => Container()),
        onUnknownRoute: (settings) =>
            MaterialPageRoute(builder: (_) => Container()),
        onPopPage: (route, result) => _onPopRootPage(route, result, pages));
  }

  /// Update route configuration when active tab [index] is changing.
  ///
  /// This will update [currentLocation] and [index] of active tab route.
  void _tabIndexUpdateHandler(int index) {
    final parentRoute = _stack.routes[index];
    final children = parentRoute.children;
    _stack = _stack.copyWith(
        currentIndex: index,
        currentLocation: children.isNotEmpty
            ? children.last.path != '/'
                ? '${parentRoute.path}${children.last.path}'
                : parentRoute.path
            : parentRoute.path);
    notifyListeners();
  }

  /// Wrap page with [AppRouter] inhertied witdget.
  ///
  /// [AppRouter.navigatorKey] field is using for nested Navigator access.
  /// [AppRouter.routerDelegate] field is using for [TabRoutesDelegate] access.
  /// [AppRouter.routePath] contains current route path.
  AppRouter _createPage(BuildContext context, RoutePath route,
      [GlobalKey<NavigatorState>? navigatorKey]) {
    return AppRouter(
        navigatorKey: navigatorKey ?? _rootNavigatorKey,
        routePath: route,
        routerDelegate: this,
        child: route.widget ?? route.builder?.call(context) ?? Container());
  }

  /// Calling when get back from nested page.
  ///
  /// It will remove a nested route in [_stack].
  bool _onPopNestedPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }

    final currentindex = _stack.currentIndex;

    // Remove last route from navigation stack.
    final rootPaths = [..._stack.routes];
    var currentStack = rootPaths[currentindex];
    final children = [...currentStack.children]..removeLast();
    rootPaths[currentindex] = currentStack.copyWith(children: children);
    _stack = _stack.copyWith(routes: rootPaths);

    // When pop route, which will pushed from another tab,
    // it will change active tab index to go back to previous tab
    //
    // todo: make it optional?
    if (!_fromDeepLink && _previousIndex != currentindex) {
      _stack = _stack.copyWith(currentIndex: _previousIndex);
      //notifyListeners();
      //return true;
    }
    notifyListeners();
    return true;
  }

  /// Calling when get back from root page.
  ///
  /// It will remove a root route in navigation stack [_stack].
  bool _onPopRootPage(
      Route<dynamic> route, dynamic result, Iterable<Page<dynamic>> pages) {
    if (!route.didPop(result)) {
      return false;
    }

    final routes = _stack.routes;

    if (pages.isNotEmpty && routes.length > 1) {
      _stack = _stack.copyWith(routes: [...routes]..removeLast());
      notifyListeners();
      return true;
    }
    return true;
  }
}
