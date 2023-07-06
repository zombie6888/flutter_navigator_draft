import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'page_transitions.dart';

enum AnimationDirection { left, down, up, right }

// Фабрика страниц для routemaster с поддержкой разных направлений анимации
// и жестов на ios
//
// todo: поменять left на right и переименовать классы так как страница выезжает справа
class PlatformPageFactory {
  static Page<dynamic> getPage(
      {AnimationDirection direction = AnimationDirection.left,
      LocalKey? key,
      String location = '',
      String routePath = '',
      String? restorationId,
      required Widget child}) {
    // todo: Добавить направления анимаций для ios, не поломав жест назад
    if (!kIsWeb && Platform.isIOS) {
      return CupertinoPage(child: child);
    } else {
      PageTransition transition = SlideLeftTransition();
      if (direction == AnimationDirection.left) {
        transition = SlideLeftTransition();
      }
      if (direction == AnimationDirection.up) {
        transition = SlideUpTransition();
      }
      if (direction == AnimationDirection.down) {
        transition = SlideDownTransition();
      }
      return TransitionPage(
          key: key,
          restorationId: restorationId,
          // location: location,
          // routePath: routePath,
          pushTransition: transition,
          popTransition: transition,
          child: child);
    }
  }
}
