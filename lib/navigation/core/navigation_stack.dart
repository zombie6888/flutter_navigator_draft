import 'route_path.dart';

class NavigationStack {
  final List<RoutePath> routes;
  final int currentIndex;
  final String currentLocation;

  NavigationStack(this.routes,
      {this.currentIndex = 0, this.currentLocation = ''});

  NavigationStack copyWith(
          {List<RoutePath>? routes,
          int? currentIndex,
          String? currentLocation}) =>
      NavigationStack(
        routes ?? this.routes,
        currentIndex: currentIndex ?? this.currentIndex,
        currentLocation: currentLocation ?? this.currentLocation,
      );

  RoutePath? getCurrentTabRoute() {
    if (routes.length - 1 >= currentIndex) {
      return routes[currentIndex];
    }
    return null;
  }
}