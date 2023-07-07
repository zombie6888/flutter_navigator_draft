import 'package:flutter/widgets.dart';

import 'custom_route_delegate.dart';
import 'custom_route_information_parser.dart';
import 'custom_route_information_provider.dart';
import 'navigation_stack.dart';
import 'route_path.dart';

class CustomRouteConfig extends RouterConfig<NavigationStack> {
  CustomRouteConfig(List<RoutePath> routes)
      : super(
            routeInformationParser:
                CustomRouteInformationParser(NavigationStack(routes)),
            routerDelegate:
                TabsRouteDelegate(routes), 
            routeInformationProvider: CustomRouteInformationProvider());
}