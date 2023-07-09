import 'package:flutter/widgets.dart';

import 'custom_route_information_parser.dart';
import 'custom_route_information_provider.dart';
import 'navigation_stack.dart';
import 'route_path.dart';
import 'tab_routes_delegate.dart';

/// Two-level navigation config for tabs.
class TabRoutesConfig extends RouterConfig<NavigationStack> {
  TabRoutesConfig(List<RoutePath> routes, TabPageBuilder builder)
      : super(
            routeInformationParser:
                CustomRouteInformationParser(NavigationStack(routes)),
            routerDelegate:
                TabRoutesDelegate(routes, builder), 
            routeInformationProvider: CustomRouteInformationProvider());
}
