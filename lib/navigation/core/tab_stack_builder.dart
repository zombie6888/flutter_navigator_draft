import 'package:flutter/material.dart';

/// Custom tab controller
///
/// It's a little bit hacky solution for the bug, when [TabBarView]
/// doesn't respect [TabController.animateTo] duration
/// It updates [animationDuration] property when
/// [TabController.animateTo] function is called, which is the only way
/// to control tab animation. The goal is disable animation
/// when index was changed by router (for example you push route, which 
/// is nested route of another tab)
/// and keep animation remaining when index was changed by user (tapping on tab).
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

class TabStackBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, TabController controller) builder;
  final int index;
  final int tabsLenght;
  final Function(int index) tabIndexUpdateHandler;
  const TabStackBuilder(
      {super.key,
      required this.builder,
      required this.tabIndexUpdateHandler,
      required this.index,
      required this.tabsLenght});

  @override
  State<TabStackBuilder> createState() => _TabStackBuilderState();
}

class _TabStackBuilderState extends State<TabStackBuilder>
    with TickerProviderStateMixin {
  late CustomTabController controller;

  @override
  void didUpdateWidget(covariant TabStackBuilder oldWidget) {
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
      length: widget.tabsLenght,
      vsync: this,
    );
    controller.addListener(_onChangeTab);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _onChangeTab() {
    if (controller.index != controller.previousIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.tabIndexUpdateHandler(controller.index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, controller);
  }
}
