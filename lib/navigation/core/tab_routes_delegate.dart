import 'package:flutter/material.dart';
import 'package:router_app/navigation/core/keep_alive_widget.dart';
import 'package:router_app/navigation/core/route_path.dart';
import 'package:router_app/navigation/core/route_utils.dart';
import 'package:router_app/navigation/transitions/platform_page_factory.dart';

import 'custom_route_delegate.dart';
import 'navigation_stack.dart';
import 'route_data.dart';
import 'tab_stack_builder.dart';

typedef TabPageBuilder = Widget Function(BuildContext context,
    Iterable<RoutePath> tabRoutes, TabBarView view, TabController controller);

class TabRoutesDelegate extends RouterDelegate<NavigationStack>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin
    implements CustomRouteDelegate {
  TabRoutesDelegate(List<RoutePath> routes, this.tabPageBuider)
      : _routes = List.unmodifiable(routes),
        _rootNavigatorKey = GlobalKey<NavigatorState>();

  final TabPageBuilder tabPageBuider;
  final GlobalKey<NavigatorState> _rootNavigatorKey;

  NavigationStack _stack = NavigationStack([]);
  final List<RoutePath> _routes;

  bool _fromDeepLink = true;
  int _previousIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _stack.currentIndex;
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
                onChangeTab: _onChangeTab,
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
                  //     body: TabBarView(
                  //       controller: controller,
                  //       children: [
                  //         for (var i = 0; i < tabRoutes.length; i++)
                  //           KeepAliveWidget(
                  //               key: ValueKey('tab_stack_${i.toString()}'),
                  //               child: getNestedNavigator(i, context)),
                  //       ],
                  //     ),
                  //     bottomNavigationBar: BottomNavigationBar(
                  //         currentIndex: selectedIndex,
                  //         type: BottomNavigationBarType.fixed,
                  //         items: <BottomNavigationBarItem>[
                  //           for (var route in tabRoutes)
                  //             BottomNavigationBarItem(
                  //               icon: const Icon(Icons.home),
                  //               label: route.path,
                  //             )
                  //         ],
                  //         selectedItemColor: Colors.amber[800],
                  //         onTap: (index) => onPressTab(controller, index)));
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

  void onPressTab(TabController controller, index) {
    controller.animateTo(index, duration: const Duration(milliseconds: 300));
  }

  void _onChangeTab(int index) {
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

  AppRouter _createPage(BuildContext context, RoutePath route,
      [GlobalKey<NavigatorState>? navigatorKey]) {
    return AppRouter(
        navigatorKey: navigatorKey ?? _rootNavigatorKey,
        routePath: route,
        routerDelegate: this,
        child: route.widget ?? route.builder?.call(context) ?? Container());
  }

  bool _onPopNestedPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }

    final currentindex = _stack.currentIndex;

    //Убираем последний роут из стека текущей табы
    final rootPaths = [..._stack.routes];
    var currentStack = rootPaths[currentindex];
    final children = [...currentStack.children]..removeLast();
    rootPaths[currentindex] = currentStack.copyWith(children: children);
    _stack = _stack.copyWith(routes: rootPaths);

    //Если перешли с другого стека то вернутся назад по истории
    //todo опционально?
    if (!_fromDeepLink && _previousIndex != currentindex) {
      _stack = _stack.copyWith(currentIndex: _previousIndex);
      //notifyListeners();
      //return true;
    }
    notifyListeners();
    return true;
  }

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

  @override
  GlobalKey<NavigatorState>? get navigatorKey => GlobalKey();

  @override
  NavigationStack? get currentConfiguration => _stack;

  //может вызываться платформой(диплинк) и приложением(pushNamed)
  @override
  Future<void> setNewRoutePath(NavigationStack configuration) async {
    _previousIndex = _stack.currentIndex;
    _stack = configuration;
    notifyListeners();
  }

  @override
  pushNamed(String path) {
    _fromDeepLink = false;
    final upadatedStack =
        RouteParseUtils(path).pushRouteToStack(_routes, _stack);
    setNewRoutePath(upadatedStack);
  }
}
