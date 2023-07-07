import 'package:flutter/material.dart';

class CustomTabController extends TabController {
  CustomTabController(
      {required super.length, required super.vsync, super.initialIndex});

  Duration? _currentDuration = const Duration(milliseconds: 300);

  @override
  Duration get animationDuration => _currentDuration ?? super.animationDuration;

  @override
  void animateTo(int value,
      {Duration? duration = Duration.zero, Curve curve = Curves.ease}) {
    _currentDuration = duration;
    super.animateTo(value, duration: duration, curve: curve);
  }
}

class TabStackController extends StatefulWidget {
  final Widget Function(BuildContext context, TabController controller) builder;
  final int index;
  const TabStackController(
      {super.key, required this.builder, required this.index});

  @override
  State<TabStackController> createState() => _TabStackControllerState();
}

class _TabStackControllerState extends State<TabStackController>
    with TickerProviderStateMixin {
  late CustomTabController controller;

  @override
  void didUpdateWidget(covariant TabStackController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (controller.index != widget.index) {      
      controller.animateTo(widget.index);
    }
  }

  @override
  void initState() {
    super.initState();
    controller = CustomTabController(
      initialIndex: widget.index,
      //animationDuration: const Duration(milliseconds: 100),
      length: 3,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, controller);
  }
}
