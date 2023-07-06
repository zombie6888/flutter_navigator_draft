import 'package:flutter/material.dart';

abstract class PageTransition {
  /// Initialize a transition for a page pop or push animation.
  const PageTransition();

  /// How long this transition animation lasts.
  Duration get duration;

  /// A builder that configures the animation.
  PageTransitionsBuilder get transitionsBuilder;
}

class TransitionPage<T> extends TransitionBuilderPage<T> {
  /// Initialize a transition page.
  ///
  /// If [pushTransition] or [popAnimation] are null, the platform default
  /// transition is used. This is the Cupertino animation on iOS and macOS, and
  /// the fade upwards animation on all other platforms.
  const TransitionPage({
    required Widget child,
    this.pushTransition,
    this.popTransition,
    bool maintainState = true,
    bool fullscreenDialog = false,
    this.location = '',
    this.routePath = '',
    bool opaque = true,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
          child: child,
          arguments: arguments,
          restorationId: restorationId,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          opaque: opaque,
          key: key,
          name: name,
        );

  final PageTransition? pushTransition;
  final PageTransition? popTransition;
  final String location;
  final String routePath;

  @override
  PageTransition buildPushTransition(BuildContext context) {
    if (pushTransition == null) {
      return SlideLeftTransition();
    }

    return pushTransition!;
  }

  @override
  PageTransition buildPopTransition(BuildContext context) {
    if (popTransition == null) {
      return SlideLeftTransition();
    }

    return popTransition!;
  }
}

abstract class TransitionBuilderPage<T> extends Page<T> {
  /// Initialize a page that provides separate push and pop animations.
  const TransitionBuilderPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.opaque = true,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
          key: key,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );

  /// Called when this page is pushed, returns a [PageTransition] to configure
  /// the push animation.
  ///
  /// Return `PageTransition.none` for an immediate push with no animation.
  PageTransition buildPushTransition(BuildContext context);

  /// Called when this page is popped, returns a [PageTransition] to configure
  /// the pop animation.
  ///
  /// Return `PageTransition.none` for an immediate pop with no animation.
  PageTransition buildPopTransition(BuildContext context);

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  /// {@macro flutter.widgets.TransitionRoute.opaque}
  final bool opaque;

  @override
  Route<T> createRoute(BuildContext context) {
    return TransitionBuilderPageRoute<T>(page: this);
  }
}

/// The route created by by [TransitionBuilderPage], which delegates push and
/// pop transition animations to that page.
class TransitionBuilderPageRoute<T> extends PageRoute<T> {
  /// Initialize a route which delegates push and pop transition animations to
  /// the provided [page].
  TransitionBuilderPageRoute({
    required TransitionBuilderPage<T> page,
  }) : super(settings: page);

  TransitionBuilderPage<T> get _page => settings as TransitionBuilderPage<T>;

  /// This value is not used.
  ///
  /// The actual durations are provides by the [PageTransition] objects.
  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: _page.child,
    );
  }

  @override
  bool didPop(T? result) {
    final transition = _page.buildPopTransition(navigator!.context);
    controller!.reverseDuration = transition.duration;
    return super.didPop(result);
  }

  @override
  TickerFuture didPush() {
    final transition = _page.buildPushTransition(navigator!.context);
    controller!.duration = transition.duration;
    return super.didPush();
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final isPopping = controller!.status == AnimationStatus.reverse;

    // If the push is complete we build the pop transition.
    // This is so cupertino back user gesture will work, even if a cupertino
    // transition wasn't used to show this page.
    final pushIsComplete = controller!.status == AnimationStatus.completed;

    final transition =
        (isPopping || pushIsComplete || navigator!.userGestureInProgress)
            ? _page.buildPopTransition(navigator!.context)
            : _page.buildPushTransition(navigator!.context);

    return transition.transitionsBuilder
        .buildTransitions(this, context, animation, secondaryAnimation, child);
  }

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  bool get opaque => _page.opaque;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}

// todo: Разбить по файлам
class SlideUpTransition extends PageTransition {
  @override
  final Duration duration = const Duration(milliseconds: 300);

  @override
  final PageTransitionsBuilder transitionsBuilder =
      const SlideUpTransitionsBuilder();
}

class SlideLeftTransition extends PageTransition {
  @override
  final Duration duration = const Duration(milliseconds: 300);

  @override
  final PageTransitionsBuilder transitionsBuilder =
      const SlideLeftTransitionsBuilder();
}

class SlideRightTransition extends PageTransition {
  @override
  final Duration duration = const Duration(milliseconds: 300);

  @override
  final PageTransitionsBuilder transitionsBuilder =
      const SlideRightTransitionsBuilder();
}

class SlideDownTransition extends PageTransition {
  @override
  final Duration duration = const Duration(milliseconds: 300);

  @override
  final PageTransitionsBuilder transitionsBuilder =
      const SlideDownTransitionsBuilder();
}

class SlideDownTransitionsBuilder extends PageTransitionsBuilder {
  const SlideDownTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _SlideDownTransitionsBuilder(
        routeAnimation: animation, child: child);
  }
}

class _SlideDownTransitionsBuilder extends StatelessWidget {
  _SlideDownTransitionsBuilder({
    Key? key,
    required Animation<double> routeAnimation,
    required this.child,
  })  : _slideAnimation = CurvedAnimation(
          parent: routeAnimation,
          curve: Curves.linear,
        ).drive(_kBottomUpTween),
        super(key: key);

  final Animation<Offset> _slideAnimation;

  static final Animatable<Offset> _kBottomUpTween = Tween<Offset>(
    begin: const Offset(0.0, -1.0),
    end: const Offset(0.0, 0.0),
  );

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _slideAnimation, child: child);
  }
}

class SlideUpTransitionsBuilder extends PageTransitionsBuilder {
  const SlideUpTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _SlideUpTransitionsBuilder(routeAnimation: animation, child: child);
  }
}

class _SlideUpTransitionsBuilder extends StatelessWidget {
  _SlideUpTransitionsBuilder({
    Key? key,
    required Animation<double> routeAnimation,
    required this.child,
  })  : _slideAnimation = CurvedAnimation(
          parent: routeAnimation,
          curve: Curves.linear,
        ).drive(_kBottomUpTween),
        super(key: key);

  final Animation<Offset> _slideAnimation;

  static final Animatable<Offset> _kBottomUpTween = Tween<Offset>(
    begin: const Offset(0.0, 1.0),
    end: const Offset(0.0, 0.0),
  );

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _slideAnimation, child: child);
  }
}

class SlideLeftTransitionsBuilder extends PageTransitionsBuilder {
  const SlideLeftTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _SlideLeftTransitionsBuilder(
        routeAnimation: animation, child: child);
  }
}

class _SlideLeftTransitionsBuilder extends StatelessWidget {
  _SlideLeftTransitionsBuilder({
    Key? key,
    required Animation<double> routeAnimation,
    required this.child,
  })  : _slideAnimation = CurvedAnimation(
          parent: routeAnimation,
          curve: Curves.linear,
        ).drive(_kBottomUpTween),
        super(key: key);

  final Animation<Offset> _slideAnimation;

  static final Animatable<Offset> _kBottomUpTween = Tween<Offset>(
    begin: const Offset(1.0, 0.0),
    end: const Offset(0.0, 0.0),
  );

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _slideAnimation, child: child);
  }
}

class SlideRightTransitionsBuilder extends PageTransitionsBuilder {
  const SlideRightTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _SlideRightTransitionsBuilder(
        routeAnimation: animation, child: child);
  }
}

class _SlideRightTransitionsBuilder extends StatelessWidget {
  _SlideRightTransitionsBuilder({
    Key? key,
    required Animation<double> routeAnimation,
    required this.child,
  })  : _slideAnimation = CurvedAnimation(
          parent: routeAnimation,
          curve: Curves.linear,
        ).drive(_kBottomUpTween),
        super(key: key);

  final Animation<Offset> _slideAnimation;

  static final Animatable<Offset> _kBottomUpTween = Tween<Offset>(
    begin: const Offset(-1.0, 0.0),
    end: const Offset(0.0, 0.0),
  );

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _slideAnimation, child: child);
  }
}
