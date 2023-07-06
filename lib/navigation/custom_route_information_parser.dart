import 'package:flutter/material.dart';
import 'package:router_app/navigation/route_path.dart';
import 'package:router_app/navigation/route_utils.dart';

import 'custom_route_config.dart';

class CustomRouteInformationParser extends RouteInformationParser<NavigationStack> {
  final List<RoutePath> _routes;
  CustomRouteInformationParser(NavigationStack stack) : _routes = stack.routes;

  @override
  Future<NavigationStack> parseRouteInformation(
      RouteInformation routeInformation) async {
    return RouteUtils.restoreRouteStack(routeInformation.location, _routes);
    // return RouteUtils.uriToRoutes(routeInformation.location, _routes.stack);
  }

  @override
  RouteInformation? restoreRouteInformation(NavigationStack configuration) {
    final RoutePath? lastRoute =
        configuration.routes.isNotEmpty ? configuration.routes.last : null;
    final isBranchRoute = lastRoute?.children.isNotEmpty ?? true;
    if (!isBranchRoute && lastRoute != null) {
      return RouteInformation(
          location: '${lastRoute.path}${lastRoute.queryString}');
    }
    final route = configuration.getCurrentTabRoute();
    final children = route?.children ?? [];
    var path = route?.path ?? '';
    final nestedRoute = children.isNotEmpty ? children.last : null;
    final nestedPath = nestedRoute?.path ?? '';
    if(nestedPath == '/') {
      path = '$path${nestedRoute?.queryString ?? ''}';
    } else {
     path = '$path$nestedPath${nestedRoute?.queryString ?? ''}';
    }    
    return RouteInformation(location: path);
  }
}
