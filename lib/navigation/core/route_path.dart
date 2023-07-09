import 'package:flutter/widgets.dart';

/// Base class for routes.
///
/// Use [RoutePath.nested] constructor for child routes.
/// It supports only two-level navigation but for config like this:
/// /tab1
///   --page1
///   --page2
/// ...
/// Uri [path] could be like: /tab1/path/page1, /tab1/../../page2
/// In order to get [RoutePath]
/// from any widget, use AppRouter.of(context).routePath.
class RoutePath {
  RoutePath(this.path, this.widget,
      {this.queryParams,
      this.params,
      this.builder,
      List<RoutePath> children = const [],
      this.navigatorKey})
      : children = List.unmodifiable(children);

  /// takes from [Uri.queryParameters]
  final Map<String, String>? queryParams;

  /// Nested routes
  final List<RoutePath> children;

  final Map<String, String>? params;

  /// Path to route like: /tab1/page1
  final String path;

  /// Can use builder or Widget for page rendering
  final Widget? widget;
  final WidgetBuilder? builder;

  /// Navigator key for parent [Navigator]. Used by [AppRouter]
  /// to get state of nested navigator
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
