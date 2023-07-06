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
      : _routes = List.unmodifiable(routes),
        location = '';
  List<RoutePath> stack = [];
  String location;
  final List<RoutePath> _routes;
  int _selectedIndex = 0;
  bool _fromDeepLink = true;
  int _previousIndex = 0;

  Widget getNestedNavigator(int index, BuildContext context) {
    final nestedPages = stack[index]
        .children
        .map(
          (p) => PlatformPageFactory.getPage(

              // location: location,
              // // routePath: '${p.path}${p.queryString}',
              // key: p.path == '/' ? const ValueKey('home') : null,
              // restorationId: p.path == '/' ? 'home' : null,
              child: Container(child: p.widget ?? Container())),
        )
        .toList();

    if (nestedPages.isEmpty) {
      return routeNotFoundPath.widget!;
    }

    if (index == 0) {
      print(stack[index].children.map((c) => c.path));
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
          rootPaths[_selectedIndex] = currentStack.copyWith(children: children);
          stack = rootPaths;

          //Если перешли с другого стека то вернутся назад по истории
          //todo опционально?
          if (!_fromDeepLink && _previousIndex != _selectedIndex) {
            _selectedIndex = _previousIndex;
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
      'from deep link: $_fromDeepLink, location: $location',
    );
    if (stack.isEmpty) {
      return routeNotFoundPath.widget!;
    }

    final pages = stack.where((e) => e.children.isEmpty).map(
          (p) => PlatformPageFactory.getPage(child: p.widget ?? Container()),
        );

    return Navigator(
      //key: ValueKey('dsfsd'),
      pages: [
        MaterialPage(
          child: TabStackController(
              index: _selectedIndex,
              builder: (context, controller) {
            print('index: ${controller.index}, $_selectedIndex');
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
                     controller.animateTo(_selectedIndex,
                        duration: const Duration(milliseconds: 300));
                    //DefaultTabController.of(context)
                    //    .animateTo(_selectedIndex);                   
                    final parentRoute = stack[_selectedIndex];
                    final children = parentRoute.children;
                    location = children.isNotEmpty
                        ? children.last.path != '/'
                            ? '${parentRoute.path}${children.last.path}'
                            : parentRoute.path
                        : parentRoute.path;
                    notifyListeners();
                    // Future.delayed(
                    //     const Duration(milliseconds: 200),
                    //     () => DefaultTabController.of(context).animateTo(
                    //         _selectedIndex,
                    //         duration: const Duration(milliseconds: 10)));
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
  Routes? get currentConfiguration => Routes(stack, tabIndex: _selectedIndex);

  //может вызываться платформой(диплинк) и приложением(pushNamed)
  @override
  Future<void> setNewRoutePath(Routes configuration) async {
    print('set new route path');
    stack = configuration.stack;
    location = configuration.currentLocation;
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
