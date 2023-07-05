import 'dart:ui';

import 'package:flutter/material.dart';

class CustomRouteInformationProvider extends PlatformRouteInformationProvider {
  CustomRouteInformationProvider()
      : super(
            initialRouteInformation: RouteInformation(
                location: PlatformDispatcher.instance.defaultRouteName));

  @override
  Future<bool> didPushRoute(String route) {
    // TODO: implement didPushRoute
    return super.didPushRoute(route);
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    // TODO: implement didPushRouteInformation
    return super.didPushRouteInformation(routeInformation);
  }

  @override
  void routerReportsNewRouteInformation(RouteInformation routeInformation,
      {RouteInformationReportingType type =
          RouteInformationReportingType.none}) {
    // TODO: implement routerReportsNewRouteInformation
    print('routerReportsNewRouteInformation');
    super.routerReportsNewRouteInformation(routeInformation, type: type);
  }
}
