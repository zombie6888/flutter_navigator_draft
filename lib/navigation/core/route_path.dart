import 'package:flutter/widgets.dart';

class RoutePath {
  const RoutePath(this.path, this.widget,
      {this.queryParams,
      this.params,
      this.builder,
      this.children = const [],
      this.navigatorKey});

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

const routeNotFoundPath = RoutePath('/', Text("route not found"));
