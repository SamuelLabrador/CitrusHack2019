import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui';
import 'dart:async';
import 'dart:io';

import 'camera_page.dart';
import 'pager.dart';
import 'circle_button.dart';
import 'shade.dart';

class EntryPoint extends StatefulWidget {
  _EntryPointState createState() => new _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  final PageController pagerController =
      new PageController(keepPage: true, initialPage: 1);

  double buttonDiameter = 100.0;
  double offsetRatio = 0.0;
  double offsetFromOne = 0.0;

  bool onPageView(ScrollNotification notification) {
    if (notification.depth == 0 && notification is ScrollUpdateNotification) {
      setState(() {
        offsetFromOne = 1.0 - pagerController.page;
        offsetRatio = offsetFromOne.abs();
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return new MediaQuery(
      data: new MediaQueryData.fromWindow(window),
      child: new Directionality(
        textDirection: TextDirection.ltr,
        child: new Scaffold(
          body: new Stack(
            children: <Widget>[

              new CameraHome(),

              new Shade(
                opacity: offsetRatio,
                isLeft: offsetFromOne > 0,
              ),

              new NotificationListener<ScrollNotification>(
                onNotification: onPageView,
                child: new Pager(
                  controller: pagerController,
                  centerWidget:
                    new ControlsLayer(
                        offset: offsetRatio,
                        onTap: () async{
                          takePic(context);
                        },
                        cameraIcon: new CameraIcon(),
                        onCameraTap: () async {
                          await flipCamera();
                          setState(() {});
                        },
                    ),
                  leftWidget: new ItemList(
                    amount: 30,
                  ),
                  rightWidget: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:[
                        Container(
                          padding: const EdgeInsets.only(top:20.0),
                          child:
                            ButtonTheme(
                                minWidth: 400,
                                height: 50,
                                child: new RaisedButton(
                                    onPressed: null,
                                    child:
                                    Text(
                                        'Settings',
                                        style: TextStyle(
                                          color: Colors.white,
                                        )
                                    )
                                )
                            )
                        ),
                        Container(
                            padding: EdgeInsets.only(top:10),
                            child:
                              ButtonTheme(
                                  minWidth: 400,
                                  height: 50,
                                  child: new RaisedButton(
                                      onPressed: null,
                                      child:
                                      Text(
                                          'Logout',
                                          style: TextStyle(
                                            color: Colors.white,
                                          )
                                      )
                                  )
                              )
                        )
                      ]
                  ),
                )
              ),
            ],
          ),
        )
      )
    );
  }
}

class ItemList extends StatelessWidget {
  final int amount;

  ItemList({this.amount});

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    for (int i = 0; i < amount; i++) {
      children.add(new ListTile(
        title: new Text('tile $i'),
      ));
    }

    return new ListView(
      children: children,
    );
  }
}

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(MaterialApp(
        home: EntryPoint(),
      ));
    });
}
