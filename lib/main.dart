import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:ui';
import 'dart:async';
import 'dart:io';

import 'camera_page.dart';
import 'login_page.dart';
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
                  leftWidget: new ItemList(),
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

  ItemList();

  @override
  Widget build(BuildContext context) {
    var reference = FirebaseDatabase.instance.reference();
    var targetref = reference.child('history').orderByChild('date');


    return StreamBuilder(
      stream: targetref.onValue,
      builder: (context, snap){
        if (snap.hasData && !snap.hasError && snap.data.snapshot.value!=null){
          //taking the data snapshot.
          DataSnapshot snapshot = snap.data.snapshot;
          List item=[];
          List fat=[];
          List calories=[];
          List carbs= [];
          List protein = [];

          Map<dynamic, dynamic> values= snapshot.value;
          values.forEach((keys,values){
            if(values!=null){
              print(item.length);
              item.add(values["food"]);
              fat.add(values["fat"]);
              calories.add(values["calories"]);
              carbs.add(values["carbs"]);
              protein.add(values["protein"]);

            }
          }
          );
          return snap.data.snapshot.value == null
              ? SizedBox()
              : ListView.builder(

            scrollDirection: Axis.vertical,

            itemCount: item.length,

            itemBuilder: (context, index) {

              return Row(
                children:[
                  Container(
                      padding: const EdgeInsets.all(10.0),
                      color: Colors.blueGrey,
                      child:
                      Text(item.elementAt(index)+"Calories: "+ calories.elementAt(index).toString()+ " Fat: "+fat.elementAt(index).toString()+" Carbs: "+ carbs.elementAt(index).toString()+ " Protein: " + protein.elementAt(index).toString(),
                        style: TextStyle(fontSize: 20.0,)
                      )
                  )
                ]
              );

            },

          );
        }
        else {

          return   Center(child: CircularProgressIndicator());

        }
      },
    );
  }
}



void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(MaterialApp(
        home: new EntryPoint(),
      ));
    });
}
