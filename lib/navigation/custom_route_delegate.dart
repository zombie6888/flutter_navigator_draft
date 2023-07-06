import 'package:flutter/material.dart';
import 'package:router_app/navigation/keep_alive_widget.dart';
import 'package:router_app/navigation/route_path.dart';
import 'package:router_app/navigation/route_utils.dart';
import 'package:router_app/navigation/transitions/platform_page_factory.dart';

import 'custom_route_config.dart';
import 'tab_stack_controller.dart';

class MyRoute extends Route {
  MyRoute({super.settings});
}

class CustomRouteDelegate extends RouterDelegate<NavigationStack>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  CustomRouteDelegate(List<RoutePath> routes) : _routes = routes;
  List<RoutePath> stack = [];
  final List<RoutePath> _routes;

  @override
  Widget build(BuildContext context) {
    final pages =
        stack.map((p) => MaterialPage(child: p.widget ?? Container())).toList();

    if (pages.isEmpty) {
      return routeNotFoundPath.widget!;
    }
    return Navigator(
      pages: pages,
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (_) => Container()),
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (_) => Container()),
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        stack = [...stack]..removeLast();
        notifyListeners();
        return true;
      },
    );
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => GlobalKey();

  @override
  NavigationStack? get currentConfiguration => NavigationStack(stack);

  @override
  Future<void> setNewRoutePath(NavigationStack configuration) async {
    print('set new route path');
    stack = configuration.routes;
    notifyListeners();
  }

  pushNamed(String path) {
    final newStack = [
      ...stack,
      ...RouteUtils.pathToRoutes(path, NavigationStack(_routes))..removeAt(0)
    ];
    setNewRoutePath(NavigationStack(newStack));
  }
}

class TabsRouteDelegate extends RouterDelegate<NavigationStack>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  TabsRouteDelegate(List<RoutePath> routes)
      : _routes = List.unmodifiable(routes);

  NavigationStack stack = NavigationStack([]);  
  final List<RoutePath> _routes;
  
  bool _fromDeepLink = true;
  int _previousIndex = 0;

  Widget getNestedNavigator(int index, BuildContext context) {
    final currentindex = stack.currentIndex;
    final nestedPages = stack.routes[index].children
        .map(
          (p) => PlatformPageFactory.getPage(
              child: Container(child: p.widget ?? Container())),
        )
        .toList();

    if (nestedPages.isEmpty) {
      return routeNotFoundPath.widget!;
    }

    if (index == 0) {
      print(stack.routes[index].children.map((c) => c.path));
    }

    return Navigator(
        //key: ValueKey('tab_$index'),
        pages: nestedPages,
        onGenerateRoute: (settings) =>
            MaterialPageRoute(builder: (_) => Container()),
        onUnknownRoute: (settings) =>
            MaterialPageRoute(builder: (_) => Container()),
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          //Убираем последний роут из стека текущей табы
          final rootPaths = [...stack.routes];
          var currentStack = rootPaths[currentindex];
          final children = [...currentStack.children]..removeLast();
          rootPaths[currentindex] = currentStack.copyWith(children: children);
          stack = stack.copyWith(routes: rootPaths);

          //Если перешли с другого стека то вернутся назад по истории
          //todo опционально?
          if (!_fromDeepLink && _previousIndex != currentindex) {
            stack = stack.copyWith(currentIndex: _previousIndex);
            //DefaultTabController.of(context).index = _selectedIndex;
            //notifyListeners();
            //return true;
          }
          notifyListeners();
          return true;
        });
  }

  @override
  Widget build(BuildContext context) {
    print(
      'from deep link: $_fromDeepLink, location: ${stack.currentLocation}',
    );
    final selectedIndex = stack.currentIndex;
    final routes = stack.routes;
    if (routes.isEmpty) {
      return routeNotFoundPath.widget!;
    }

    final pages = routes.where((e) => e.children.isEmpty).map(
          (p) => PlatformPageFactory.getPage(child: p.widget ?? Container()),
        );

    return Navigator(
      //key: ValueKey('dsfsd'),
      pages: [
        MaterialPage(
          child: TabStackController(
              index: stack.currentIndex,
              builder: (context, controller) {
                print('index: ${controller.index}, ${selectedIndex}');
                // controller.animateTo(_selectedIndex,
                //     duration: const Duration(milliseconds: 300));
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
                      onTap: (index) {
                        stack = stack.copyWith(currentIndex: index);
                        controller.animateTo(index,
                            duration: const Duration(milliseconds: 300));
                        //DefaultTabController.of(context)
                        //    .animateTo(_selectedIndex);
                        final parentRoute = routes[index];
                        final children = parentRoute.children;
                        stack = stack.copyWith(
                            currentIndex: index,
                            currentLocation: children.isNotEmpty
                                ? children.last.path != '/'
                                    ? '${parentRoute.path}${children.last.path}'
                                    : parentRoute.path
                                : parentRoute.path);
                        notifyListeners();
                      }),
                );
              }),
        ),
        ...pages
      ],
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (_) => Container()),
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (_) => Container()),
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (pages.isNotEmpty && routes.length > 1) {
          stack = stack.copyWith(routes: [...routes]..removeLast());
          notifyListeners();
          return true;
        }
        return true;
      },
    );
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => GlobalKey();

  @override
  NavigationStack? get currentConfiguration => stack;

  //может вызываться платформой(диплинк) и приложением(pushNamed)
  @override
  Future<void> setNewRoutePath(NavigationStack configuration) async {
    print('set new route path');
    _previousIndex = stack.currentIndex;
    stack = configuration;   
    notifyListeners();
  }

  pushNamed(String path) {
    _fromDeepLink = false;
    final upadatedStack = RouteUtils.pushRouteToStack(
        path, _routes, stack);
    setNewRoutePath(upadatedStack);
  }
}
