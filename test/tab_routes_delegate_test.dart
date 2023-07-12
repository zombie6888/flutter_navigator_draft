import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:router_app/navigation/core/custom_route_information_parser.dart';
import 'package:router_app/navigation/core/navigation_observer.dart';
import 'package:router_app/navigation/core/route_path.dart';
import 'package:router_app/navigation/core/tab_routes_config.dart';
import 'package:router_app/navigation/core/tab_routes_delegate.dart';
import 'package:router_app/navigation/platform_tabs_page.dart';

import 'pages.dart';
import 'test_routes.dart';

void main() {
  late TabRoutesConfig config;
  late List<String> log;
  TestWidgetsFlutterBinding.ensureInitialized();
  late TabRoutesDelegate delegate;
  late CustomRouteInformationParser parser;

  group('TabRoutesDelegate', () {
    setUp(() {
      config = TabRoutesConfig(
          routes: tabRoutes,
          observer: LocationObserver(),
          builder: (context, tabRoutes, view, controller) => PlatformTabsPage(
              tabRoutes: tabRoutes, view: view, controller: controller));

      delegate = config.routerDelegate as TabRoutesDelegate;
      parser = config.routeInformationParser as CustomRouteInformationParser;
    });
    group('Push route', () {
      test('Pushed to root stack', () async {
        await delegate.pushNamed('/page6');
        expect(
          delegate.currentConfiguration?.routes.last,
          RoutePath('/page6', null),
        );
        expect(delegate.currentConfiguration?.currentLocation, '/page6');
      });
      test('Pushed to deep stack', () async {
         final stack =
            await parser.parseRouteInformation(const RouteInformation(location: '/'));
        await delegate.setNewRoutePath(stack);
        await delegate.pushNamed('/tab1/page5');
        expect(
          delegate.currentConfiguration?.routes[0].children.last,
          RoutePath('/page5', null),
        );
        expect(delegate.currentConfiguration?.currentLocation, '/tab1/page5');
      });
    });
    group('Set route from platform', () {
      test('deep link to root route', () async {
        final stack =
            await parser.parseRouteInformation(const RouteInformation(location: '/page6'));
        await delegate.setNewRoutePath(stack);
        expect(
          delegate.currentConfiguration?.routes.last,
          RoutePath('/page6', null),
        );
      });
    });
  });
}
