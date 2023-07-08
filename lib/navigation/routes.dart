import 'package:router_app/navigation/core/route_path.dart';
import 'package:router_app/navigation/tabs_page.dart';

import '../main.dart';
import 'core/tab_routes_config.dart';
import 'platform_tabs_page.dart';

final routeConfig = TabRoutesConfig(
    tabRoutes,
    (context, tabRoutes, view, controller) =>
        PlatformTabsPage(tabRoutes: tabRoutes, view: view, controller: controller));

final tabRoutes = List<RoutePath>.unmodifiable([
  RoutePath.nested(
      '/tab1',
      List<RoutePath>.unmodifiable([
        const RoutePath('/', HomePage()),
        const RoutePath('/page4', Page4()),
        const RoutePath('/page5', Page5()),
        const RoutePath('/nestedtest/page7', Page7()),
      ])),
  RoutePath.nested('/tab2', [
    const RoutePath('/page1', Page1()),
    const RoutePath('/page8', Page8()),
  ]),
  RoutePath.nested('/tab3', [const RoutePath('/page2', Page2())]),
  const RoutePath('/tab1/page6', Page6()),
]);
