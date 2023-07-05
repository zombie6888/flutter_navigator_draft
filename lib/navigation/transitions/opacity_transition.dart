import 'package:flutter/material.dart';
import 'page_transitions.dart';

class OpacityTransition extends PageTransition {
  @override
  final Duration duration = const Duration(milliseconds: 300);

  @override
  final PageTransitionsBuilder transitionsBuilder =
       const OpacityPageRouteBuilder();  
}

class OpacityPageRouteBuilder extends PageTransitionsBuilder {
  const OpacityPageRouteBuilder();

   @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _OpacityTransitionsBuilder(
        routeAnimation: animation, child: child);
  }

  // OpacityPageRouteBuilder({
  //   required WidgetBuilder builder,
  //   RouteSettings? settings,
  //   bool maintainState = true,
  //   bool fullscreenDialog = false,
  // }) 

  // @override
  // Widget buildTransitions(BuildContext context, Animation<double> animation,
  //     Animation<double> secondaryAnimation, Widget child) {        
  //   return _OpacityTransitionsBuilder(routeAnimation: animation, child: child);
  // }
}

// class _SlideDownTransitionsBuilder extends StatelessWidget {
//   _SlideDownTransitionsBuilder({
//     Key? key,
//     required Animation<double> routeAnimation,
//     required this.child,
//   })  : _slideAnimation = CurvedAnimation(
//           parent: routeAnimation,
//           curve: Curves.linear,
//         ).drive(_kBottomUpTween),
//         super(key: key);

//   final Animation<Offset> _slideAnimation;

//   static final Animatable<Offset> _kBottomUpTween = Tween<Offset>(
//     begin: const Offset(0.0, -1.0),
//     end: const Offset(0.0, 0.0),
//   );

//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     return SlideTransition(position: _slideAnimation, child: child);
//   }
// }

class _OpacityTransitionsBuilder extends StatelessWidget {
  _OpacityTransitionsBuilder({
    Key? key,
    required Animation<double> routeAnimation,
    required this.child,
    }) : _opacityAnimation = routeAnimation.drive(_easeInTween),
  // })  : _slideAnimation = CurvedAnimation(
  //         parent: routeAnimation,
  //         curve: Curves.linear,
  //       ).drive(_kBottomUpTween),
        super(key: key);

  final Animation<double> _opacityAnimation;
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);

  // static final Animatable<Opacity> _kBottomUpTween = Tween<Opacity>(
  //   begin: Opacity(0.0, 1.0),
  //   end: const Offset(0.0, 0.0),
  // );

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacityAnimation, child: child);
  }
}