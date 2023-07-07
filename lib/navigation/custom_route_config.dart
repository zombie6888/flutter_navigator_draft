import 'package:flutter/widgets.dart';
import 'package:router_app/navigation/custom_route_delegate.dart';
import 'package:router_app/navigation/custom_route_information_parser.dart';
import 'package:router_app/navigation/route_path.dart';

import '../main.dart';
import 'custom_route_information_provider.dart';

class NavigationStack {
  final List<RoutePath> routes;
  final int currentIndex;
  final String currentLocation;

  NavigationStack(this.routes,
      {this.currentIndex = 0, this.currentLocation = ''});

  NavigationStack copyWith(
          {List<RoutePath>? routes,
          int? currentIndex,
          String? currentLocation}) =>
      NavigationStack(
        routes ?? this.routes,
        currentIndex: currentIndex ?? this.currentIndex,
        currentLocation: currentLocation ?? this.currentLocation,
      );

  RoutePath? getCurrentTabRoute() {
    if (routes.length - 1 >= currentIndex) {
      return routes[currentIndex];
    }
    return null;
  }
}

class CustomRouteConfig extends RouterConfig<NavigationStack> {
  CustomRouteConfig(List<RoutePath> routes)
      : super(
            routeInformationParser:
                CustomRouteInformationParser(NavigationStack(routes)),
            routerDelegate:
                TabsRouteDelegate(routes), //CustomRouteDelegate(routes),
            routeInformationProvider: CustomRouteInformationProvider());
}

// final routes = [
//   const RoutePath('/', HomePage()),
//   const RoutePath('/page1', Page1()),
//   const RoutePath('/page2', Page2()),
// ];

final tabRoutes = List<RoutePath>.unmodifiable([
  RoutePath.nested(
      '/tab1',
      List<RoutePath>.unmodifiable([
        const RoutePath('/', HomePage()),
        const RoutePath('/page4', Page4()),
        const RoutePath('/page5', Page5()),
        const RoutePath('/nestedtest/page7', Page7()),
      ])),
  RoutePath.nested('/tab2', [const RoutePath('/page1', Page1())]),
  RoutePath.nested('/tab3', [const RoutePath('/page2', Page2())]),
  const RoutePath('/tab1/page6', Page6())
]);

final routeConfig = CustomRouteConfig(tabRoutes);
final router = routeConfig.routerDelegate as TabsRouteDelegate;
