import 'package:flutter/material.dart';
import 'package:router_app/navigation/keep_alive_widget.dart';
import 'package:router_app/navigation/route_path.dart';
import 'package:router_app/navigation/route_utils.dart';
import 'package:router_app/navigation/transitions/platform_page_factory.dart';

import 'custom_route_config.dart';
import 'route_data.dart';
import 'tab_stack_controller.dart';

class TabsRouteDelegate extends RouterDelegate<NavigationStack>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  TabsRouteDelegate(List<RoutePath> routes)
      : _routes = List.unmodifiable(routes);

  NavigationStack _stack = NavigationStack([]);
  final List<RoutePath> _routes;

  bool _fromDeepLink = true;
  int _previousIndex = 0;

  Widget getNestedNavigator(int index, BuildContext context) {
    final nestedPages = _stack.routes[index].children
        .map(
          (route) =>
              PlatformPageFactory.getPage(child: _createPage(context, route)),
        )
        .toList();

    if (nestedPages.isEmpty) {
      return routeNotFoundPath.widget!;
    }

    return Navigator(
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

    return Navigator(
        pages: [
          MaterialPage(
            child: TabStackController(
                index: _stack.currentIndex,
                builder: (context, controller) {
                  return Scaffold(
                      body: TabBarView(
                        controller: controller,
                        children: [
                          KeepAliveWidget(
                              key: const ValueKey('tab_1'),
                              child: getNestedNavigator(0, context)),
                          KeepAliveWidget(
                              key: const ValueKey('tab_2'),
                              child: getNestedNavigator(1, context)),
                          KeepAliveWidget(
                              key: const ValueKey('tab_3'),
                              child: getNestedNavigator(2, context)),
                        ],
                      ),
                      bottomNavigationBar: BottomNavigationBar(
                          currentIndex: selectedIndex,
                          items: <BottomNavigationBarItem>[
                            for (var route in routes)
                              BottomNavigationBarItem(
                                icon: const Icon(Icons.home),
                                label: route.path,
                              )
                          ],
                          selectedItemColor: Colors.amber[800],
                          onTap: (index) => onPressTab(controller, index)));
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

  RouteData _createPage(BuildContext context, RoutePath route) {
    return RouteData(
        routePath: route,
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

  pushNamed(String path) {
    _fromDeepLink = false;
    final upadatedStack =
        RouteParseUtils(path).pushRouteToStack(_routes, _stack);
    setNewRoutePath(upadatedStack);
  }
}
