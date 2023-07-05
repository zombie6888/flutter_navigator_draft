import 'package:flutter/widgets.dart';
import 'package:router_app/navigation/custom_route_delegate.dart';
import 'package:router_app/navigation/custom_route_information_parser.dart';
import 'package:router_app/navigation/route_path.dart';

import '../main.dart';
import 'custom_route_information_provider.dart';

class Routes {
  final List<RoutePath> stack;
  final int tabIndex;

  Routes(this.stack, [this.tabIndex = 0]);
  
  RoutePath? getCurrentTabRoute() {
    if(stack.length - 1 >= tabIndex) {
       return stack[tabIndex];
    }
    return null;     
  }
}

class CustomRouteConfig extends RouterConfig<Routes> {
  CustomRouteConfig(List<RoutePath> routes)
      : super(
            routeInformationParser: CustomRouteInformationParser(Routes(tabRoutes)),
            routerDelegate:
                TabsRouteDelegate(tabRoutes), //CustomRouteDelegate(routes),
            routeInformationProvider: CustomRouteInformationProvider());
}

final routes = [
  const RoutePath('/', HomePage()),
  const RoutePath('/page1', Page1()),
  const RoutePath('/page2', Page2()),
];

final tabRoutes = List<RoutePath>.unmodifiable([
  RoutePath.nested('/tab1', List<RoutePath>.unmodifiable([
    const RoutePath('/', HomePage()),
    const RoutePath('/page4', Page4()),
    const RoutePath('/page5', Page5()),    
  ])),
  RoutePath.nested('/tab2', [const RoutePath('/page1', Page1())]),
  RoutePath.nested('/tab3', [const RoutePath('/page2', Page2())]),
  const RoutePath('/tab1/page6', Page6()) 
]);

final routeConfig = CustomRouteConfig(routes);
final router = routeConfig.routerDelegate as TabsRouteDelegate;
