import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:router_app/navigation/core/custom_route_information_parser.dart';
import 'package:router_app/navigation/core/navigation_observer.dart';
import 'package:router_app/navigation/core/route_path.dart';
import 'package:router_app/navigation/core/tab_routes_config.dart';
import 'package:router_app/navigation/platform_tabs_page.dart';

import 'test_routes.dart';

void main() {
  late TabRoutesConfig config;
  TestWidgetsFlutterBinding.ensureInitialized();
  late CustomRouteInformationParser parser;

  group('CustomRouteInformationParser', () {
    setUp(() {
      config = TabRoutesConfig(
          routes: tabRoutes,
          observer: LocationObserver(),
          builder: (context, tabRoutes, view, controller) => PlatformTabsPage(
              tabRoutes: tabRoutes, view: view, controller: controller));
      
      parser = config.routeInformationParser as CustomRouteInformationParser;
    });
    group('Convert route infromation to configarion', () {
      test('Deep link to root route', () async {
        final stack = await parser
            .parseRouteInformation(const RouteInformation(location: '/page6'));       
        expect(
          stack.routes.last,
          RoutePath('/page6', null),
        );
      });
      test('Deep link to tab route', () async {
        final stack = await parser.parseRouteInformation(
            const RouteInformation(location: '/tab2/page1'));        
        expect(
          stack.routes[1].children.last,
          RoutePath('/page1', null),
        );       
      });
      test('Deep link to tab nested route', () async {
        final stack = await parser.parseRouteInformation(
            const RouteInformation(location: '/tab3/nestedtest/page7'));      
        expect(
          stack.routes[2].children.last,
          RoutePath('/nestedtest/page7', null),
        );        
      });      
    });
    group('Convert configarion to route infromation', () {

    });
  });
}
