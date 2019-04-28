import 'package:flutter/material.dart';

class Pager extends StatelessWidget {
  final PageController controller;
  final Widget leftWidget;
  final Widget rightWidget;
  final Widget centerWidget;
  Pager({this.controller, this.centerWidget, this.leftWidget, this.rightWidget});

  Iterable<Widget> buildPages() {
    final List<Widget> pages = <Widget>[];

    pages.add(_contentWidget(Colors.white, Colors.white, leftWidget));
    pages.add(centerWidget);
    pages.add(_contentWidget(Colors.white, Colors.white, rightWidget));
    return pages;
  }

  _contentWidget(Color color,Color background, [Widget page]) {
    var widgets = <Widget>[];
    widgets.add(new Opacity(
      opacity: 0.0,
      child: new Container(
        color: color,
      ),
    ));
    if (page != null) {
      widgets.add(new Positioned.fill(
        child: new Container(
          margin: new EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
          child: page,
          decoration: new ShapeDecoration(
            color: background,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.only(
                topLeft: new Radius.circular(10.0),
                topRight: new Radius.circular(10.0)
              )
            )
          ),
        ),
      ));
    }

    return new Stack(
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Positioned.fill(
        child: new Directionality(
          textDirection: TextDirection.ltr,
          child: new PageView(
            controller: controller,
            children: buildPages(),
          ),
        )
      );
  }
}

