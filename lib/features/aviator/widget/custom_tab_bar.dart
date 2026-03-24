import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> tabViews;
  final Color backgroundColor;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color selectedTabColor;
  final Color unselectedTextColor;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.backgroundColor = Colors.transparent,
    this.borderRadius = 52,
    this.borderWidth = 1,
    this.borderColor = Colors.white24,
    this.selectedTabColor = Colors.white24,
    this.unselectedTextColor = Colors.white,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.borderColor,
              width: widget.borderWidth,
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: widget.selectedTabColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: widget.unselectedTextColor,
            dividerColor: Colors.transparent,
            tabs: widget.tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        const SizedBox(height: 16),
        IndexedStack(
          index: _tabController.index,
          children: widget.tabViews,
        ),
      ],
    );
  }
}
