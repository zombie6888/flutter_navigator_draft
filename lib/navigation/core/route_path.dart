import 'package:flutter/widgets.dart';

class RoutePath {
  RoutePath(this.path, this.widget,
      {this.queryParams,
      this.params,
      this.builder,
      List<RoutePath> children = const [],
      this.navigatorKey})
      : children = List.unmodifiable(children);

  final Map<String, String>? queryParams;
  final List<RoutePath> children;
  final Map<String, String>? params;
  final String path;
  final Widget? widget;
  final WidgetBuilder? builder;

  final GlobalKey<NavigatorState>? navigatorKey;

  String get queryString {
    final query = Uri(queryParameters: queryParams).query;
    return query.isNotEmpty ? '?$query' : '';
  }

  @override
  bool operator ==(covariant RoutePath other) =>
      other.path == path && other.queryString == queryString;

  RoutePath copyWith(
          {List<RoutePath>? children, Map<String, String>? queryParams}) =>
      RoutePath(path, widget,
          navigatorKey: navigatorKey,
          queryParams: queryParams ?? this.queryParams,
          children: children ?? this.children,
          params: params,
          builder: builder);

  RoutePath.nested(this.path, this.children,
      {this.queryParams, this.params, this.builder})
      : widget = null,
        navigatorKey = GlobalKey<NavigatorState>();

  @override
  int get hashCode => '$path$queryString'.hashCode;
}

final routeNotFoundPath = RoutePath('/', const Text("route not found"));
