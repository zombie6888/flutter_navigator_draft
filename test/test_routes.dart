import 'package:router_app/navigation/core/route_path.dart';
import 'package:router_app/navigation/redirect_widget.dart';

import '../lib/pages.dart';

final tabRoutes = [
  RoutePath.branch('/tab1', [
    RoutePath('/', const HomePage()),
    RoutePath('/page4', const Page4()),
    RoutePath('/page5', const Page5()),
    RoutePath('/nestedtest/page7', const Page7()),
  ]),
  RoutePath.branch('/tab2', [
    RoutePath('/page1', const Page1()),
    RoutePath('/page5', const Page5()),
    RoutePath('/page9', const Page9()),
    RoutePath.builder(
        '/page8', (context) => const RedirectWidget(path: '/tab1/page5'))
  ]),
  RoutePath('/page1', const Page8()),
  RoutePath.branch('/tab3', [
    RoutePath('/page2', const Page2()),
    RoutePath('/nestedtest/page7', const Page7()),
  ]),
  RoutePath('/page6', const Page6()),
  RoutePath('/page7', const RedirectWidget(path: '/tab3/nestedtest/page7')),
];
