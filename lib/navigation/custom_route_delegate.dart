import 'package:flutter/material.dart';
import 'package:router_app/navigation/route_path.dart';
import 'package:router_app/navigation/route_utils.dart';
import 'package:router_app/navigation/transitions/platform_page_factory.dart';

import 'custom_route_config.dart';

class MyRoute extends Route {
  MyRoute({super.settings});
}

class CustomRouteDelegate extends RouterDelegate<Routes>
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
  Routes? get currentConfiguration => Routes(stack);

  @override
  Future<void> setNewRoutePath(Routes configuration) async {
    print('set new route path');
    stack = configuration.stack;
    notifyListeners();
  }

  pushNamed(String path) {
    final newStack = [
      ...stack,
      ...RouteUtils.pathToRoutes(path, Routes(_routes))..removeAt(0)
    ];
    setNewRoutePath(Routes(newStack));
  }
}

class TabsRouteDelegate extends RouterDelegate<Routes>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  TabsRouteDelegate(List<RoutePath> routes)
      : _routes = List.unmodifiable(routes);
  List<RoutePath> stack = [];
  final List<RoutePath> _routes;
  int _selectedIndex = 0;
  bool _fromDeepLink = true;
  int _previousIndex = 0;

  @override
  Widget build(BuildContext context) {
    print(
      'from deep link: $_fromDeepLink',
    );
    if (stack.isEmpty) {
      return routeNotFoundPath.widget!;
    }
    //print('build');
    final nestedPages = stack[_selectedIndex]
        .children
        .map(
          (p) => PlatformPageFactory.getPage(
            //key: ValueKey(p.path),
            child: p.widget ?? Container()),
        )
        .toList();

    final pages = stack.where((e) => e.children.isEmpty).map(
          (p) => PlatformPageFactory.getPage(child: p.widget ?? Container()),
        );

    if (nestedPages.isEmpty) {
      return routeNotFoundPath.widget!;
    }

    return Navigator(
      pages: [
        MaterialPage(
          child: Scaffold(
            body: Navigator(
              pages: nestedPages,
              onGenerateRoute: (settings) =>
                  MaterialPageRoute(builder: (_) => Container()),
              onUnknownRoute: (settings) =>
                  MaterialPageRoute(builder: (_) => Container()),
              onPopPage: (route, result) {
                if (!route.didPop(result)) {
                  return false;
                }

                // if (pages.isNotEmpty) {
                //   final updatedStack = [...stack]
                //       .where((e) => e.children.isEmpty)
                //       .toList()
                //     ..removeLast();
                //   stack = updatedStack;
                //   notifyListeners();
                //   return true;
                // }
                
                //Убираем последний роут из стека текущей табы
                final rootPaths = [...stack];
                var currentStack = rootPaths[_selectedIndex];
                final children = [...currentStack.children]..removeLast();
                rootPaths[_selectedIndex] =
                    currentStack.copyWith(children: children);
                stack = rootPaths;

                //Если перешли с другого стека то вернутся назад по истории
                //todo опционально?
                if (!_fromDeepLink && _previousIndex != _selectedIndex) {
                  _selectedIndex = _previousIndex;
                  //notifyListeners();
                  //return true;
                }
                notifyListeners();
                return true;
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                items: <BottomNavigationBarItem>[
                  for (var route in stack)
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.home),
                      label: route.path,
                    )
                ],
                selectedItemColor: Colors.amber[800],
                onTap: (index) {
                  _selectedIndex = index;
                  notifyListeners();
                }),
          ),
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

        if (pages.isNotEmpty && stack.length > 1) {
          stack = [...stack]..removeLast();
          notifyListeners();
          return true;
        }

        // final rootPaths = [...stack];
        // var currentStack = rootPaths[_selectedIndex];
        // currentStack = currentStack.copyWith(
        //     children: currentStack.children..removeLast());
        // stack = rootPaths;
        // notifyListeners();
        return true;
      },

      // bottomNavigationBar: BottomNavigationBar(
      //     items: <BottomNavigationBarItem>[
      //       for (var route in _routes)
      //         BottomNavigationBarItem(
      //           icon: const Icon(Icons.home),
      //           label: route.path,
      //         )
      //       // BottomNavigationBarItem(
      //       //   icon: Icon(Icons.home),
      //       //   label: 'Home',
      //       // ),
      //       // BottomNavigationBarItem(
      //       //   icon: Icon(Icons.business),
      //       //   label: 'Business',
      //       // ),
      //       // BottomNavigationBarItem(
      //       //   icon: Icon(Icons.school),
      //       //   label: 'School',
      //       // ),
      //     ],
      //     currentIndex: _selectedIndex,
      //     selectedItemColor: Colors.amber[800],
      //     onTap: (index) {
      //       _selectedIndex = index;

      //       notifyListeners();
      //     }),
    );
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => GlobalKey();

  @override
  Routes? get currentConfiguration => Routes(stack, _selectedIndex);

  //может вызываться платформой(диплинк) и приложением(pushNamed)
  @override
  Future<void> setNewRoutePath(Routes configuration) async {
    print('set new route path');
    stack = configuration.stack;
    _previousIndex = _selectedIndex;
    _selectedIndex = configuration.tabIndex;
    notifyListeners();
  }

  pushNamed(String path) {
    _fromDeepLink = false;
    final upadatedStack =
        RouteUtils.pushPathToStack(path, _routes, stack, _selectedIndex);
    setNewRoutePath(upadatedStack);
  }
}
