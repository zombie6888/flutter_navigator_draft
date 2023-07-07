import 'package:router_app/navigation/core/custom_route_delegate.dart';
import 'package:router_app/navigation/core/route_path.dart';

import '../main.dart';
import 'core/custom_route_config.dart';

final routeConfig = CustomRouteConfig(tabRoutes);
final router = routeConfig.routerDelegate as TabsRouteDelegate;

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