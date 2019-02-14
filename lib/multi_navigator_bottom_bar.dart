library multi_navigator_bottom_bar;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomBarTab {
  final WidgetBuilder routePageBuilder;
  final WidgetBuilder initPageBuilder;
  final WidgetBuilder tabIconBuilder;
  final WidgetBuilder tabTitleBuilder;
  /// Save current `BottomBarTab` state, when changing to another `BottomBarTab`
  /// Useful for realizing Material guidelines for Android/iOS
  ///
  /// For more information refer to https://material.io/design/components/bottom-navigation.html#behavior
  final bool savePageState;

  BottomBarTab({
    @required this.initPageBuilder,
    @required this.tabIconBuilder,
    this.tabTitleBuilder,
    this.routePageBuilder,
    this.savePageState = true,
  });
}

class MultiNavigatorBottomBar extends StatefulWidget {
  final int currentTabIndex;
  final List<BottomBarTab> tabs;
  final PageRoute pageRoute;
  final ValueChanged<int> onTap;
  final Widget Function(Widget) pageWidgetDecorator;

  MultiNavigatorBottomBar(
      {@required this.currentTabIndex,
      @required this.tabs,
      this.onTap,
      this.pageRoute,
      this.pageWidgetDecorator});

  @override
  State<StatefulWidget> createState() =>
      _MultiNavigatorBottomBarState(currentTabIndex);
}

class _MultiNavigatorBottomBarState extends State<MultiNavigatorBottomBar> {
  int currentIndex;

  _MultiNavigatorBottomBarState(this.currentIndex);

  @override
  Widget build(BuildContext context) =>Scaffold(
          body: widget.pageWidgetDecorator == null
              ? _buildPageBody()
              : widget.pageWidgetDecorator(_buildPageBody()),
          bottomNavigationBar: _buildBottomBar(),

      );

  Widget _buildPageBody() {
    List<Widget> navigators = [];
    for (BottomBarTab tab in widget.tabs) {
      navigators.add(_buildOffstageNavigator(tab));
    }

    return Stack(children: navigators);
  }

  Widget _buildOffstageNavigator(BottomBarTab tab) {
    if (tab.savePageState) {
      return Offstage(
        offstage: widget.tabs.indexOf(tab) != currentIndex,
        child: TabPageNavigator(
          initPage: tab.initPageBuilder(context),
          pageRoute: widget.pageRoute,
        ),
      );
    }

    if (widget.tabs.indexOf(tab) == currentIndex) {
      return TabPageNavigator(
        initPage: tab.initPageBuilder(context),
        pageRoute: widget.pageRoute,
      );
    }

    return Container();
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      items: widget.tabs
          .map((tab) => BottomNavigationBarItem(
                icon: tab.tabIconBuilder(context),
                title: tab.tabTitleBuilder(context),
              ))
          .toList(),
      onTap: widget.onTap ?? (index) => setState(() => currentIndex = index),
      currentIndex: currentIndex,
    );
  }
}

class TabPageNavigator extends StatelessWidget {
  TabPageNavigator({@required this.initPage, this.pageRoute});

  final Widget initPage;
  final PageRoute pageRoute;

  @override
  Widget build(BuildContext context) => Navigator(
        onGenerateRoute: (routeSettings) =>
            pageRoute ??
            MaterialPageRoute(
              settings: RouteSettings(isInitialRoute: true),
              builder: (context) => _defaultPageRouteBuilder(routeSettings.name)(context),
            )
      );

  WidgetBuilder _defaultPageRouteBuilder(String routeName, {String heroTag}) {
    return (context) => initPage;
  }
}
