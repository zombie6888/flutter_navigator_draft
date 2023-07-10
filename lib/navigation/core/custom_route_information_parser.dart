import 'package:flutter/material.dart';
import 'package:router_app/navigation/core/route_path.dart';
import 'package:router_app/navigation/core/route_utils.dart';

import 'navigation_stack.dart';

/// Custom route infromation parser.
/// 
/// This class is using to convert [RouteInformation] to [NavigationStack], and 
/// get back [NavigationStack] from [RouteInformation].
/// see [RouteInformationParser]
class CustomRouteInformationParser
    extends RouteInformationParser<NavigationStack> {
  final List<RoutePath> _routes;
  CustomRouteInformationParser(NavigationStack stack) : _routes = stack.routes;

  /// Inform router about platfrom updates.
  /// Takes [RouteInformation] from platform and returns updated [NavigationStack]
  @override
  Future<NavigationStack> parseRouteInformation(
      RouteInformation routeInformation) async {
    return RouteParseUtils(routeInformation.location)
        .restoreRouteStack(_routes);
  }

  /// Inform platform about route configuration updates. 
  /// Takes [NavigationStack] from router and pass updated [RouteInformation] 
  /// to platform 
  @override
  RouteInformation? restoreRouteInformation(NavigationStack configuration) {
    final RoutePath? activeRoute =
        configuration.routes.isNotEmpty ? configuration.routes.last : null;
    final isBranchRoute = activeRoute?.children.isNotEmpty ?? true;
    if (!isBranchRoute && activeRoute != null) {
      return RouteInformation(
          location: '${activeRoute.path}${activeRoute.queryString}');
    }
    final route = configuration.getCurrentTabRoute();
    final children = route?.children ?? [];
    final path = route?.path ?? '';
    final nestedRoute = children.isNotEmpty ? children.last : null;
    final nestedPath = nestedRoute?.path ?? '';
    final query = nestedRoute?.queryString ?? '';
    if (nestedPath == '/') {
      return RouteInformation(location:'$path$query');
    } else {
      return RouteInformation(location:'$path$nestedPath$query');
    }    
  }
}
