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

class TabStackBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, TabController controller) builder;
  final int index;
  final int tabsLenght;
  final Function(int index) onChangeTab;
  const TabStackBuilder(
      {super.key,
      required this.builder,
      required this.onChangeTab,
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
    if (controller.indexIsChanging) {
      widget.onChangeTab(controller.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, controller);
  }
}
