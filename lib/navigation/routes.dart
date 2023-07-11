import 'dart:math';

import 'package:router_app/navigation/core/navigation_observer.dart';
import 'package:router_app/navigation/core/route_path.dart';
import 'package:router_app/navigation/redirect_widget.dart';

import '../main.dart';
import 'core/app_router.dart';
import 'core/tab_routes_config.dart';
import 'platform_tabs_page.dart';

final routeConfig = TabRoutesConfig(
    routes: tabRoutes, 
    observer: LocationObserver(),  
    builder: (context, tabRoutes, view, controller) => PlatformTabsPage(
        tabRoutes: tabRoutes, view: view, controller: controller));

final tabRoutes = [
  RoutePath.nested('/tab1', [
    RoutePath('/', const HomePage()),
    RoutePath('/page4', const Page4()),
    RoutePath('/page5', const Page5()),
    RoutePath('/nestedtest/page7', const Page7()),
  ]),
  RoutePath.nested('/tab2', [
    RoutePath('/page1', const Page1()),
    RoutePath('/page5', const Page5()),
    RoutePath.builder('/page8', (context) {    
      // if(Random().nextBool()) {
      //   return const Page8();
      // } else {
        return const RedirectWidget(path: '/tab3/nestedtest/page7');
      //}
    }),
  ]),
  RoutePath.nested('/tab3', [
    RoutePath('/page2', const Page2()),
    RoutePath('/nestedtest/page7', const Page7()),
  ]),
  RoutePath('/tab1/page6', const Page6()),
  RoutePath('/tab1/page7',  const RedirectWidget(path: '/tab3/nestedtest/page7')),
];
