import 'package:mlkit/mlkit.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

class itemData extends StatelessWidget{
  File fileTarget;
  List<VisionLabel> currentLabels = <VisionLabel>[];

  FirebaseVisionLabelDetector detector = FirebaseVisionLabelDetector.instance;

  //itemData({Key key,this.fileTarget}) : super(key: key);

  @override
  Widget build(BuildContext context){
    grabLabels();
    return Column(
      children: [
        new ListView.builder(
          itemCount: currentLabels.length(),
          itemBuilder: (BuildContext context int index){
            return new Text(currentLabels.[index]);
          },
        )
      ]
    )
  }
  List<VisionLabel> grabLabels()async{
    return await detector.detectFromBinary(fileTarget ?.readAsBytesSync());
  }
}