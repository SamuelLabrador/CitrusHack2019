import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_database/firebase_database.dart';


List<CameraDescription> _cameras;
CameraController _controller;

IconData _cameraLensIcon(CameraLensDirection currentDirection) {
  switch (currentDirection) {
    case CameraLensDirection.back:
      return Icons.camera_front;
    case CameraLensDirection.front:
      return Icons.camera_rear;
    case CameraLensDirection.external:
      return Icons.camera;
  }

  throw new ArgumentError('Unknown lens direction');
}


void takePic(BuildContext context) async{
  try {
    // Construct the path where the image should be saved using the path
    // package.
    final path = join(
      // In this example, store the picture in the temp directory. Find
      // the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );

  // Attempt to take a picture and log where it's been saved
    await _controller.takePicture(path);

  // If the picture was taken, display it on a new screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => cameraDecision(imagePath: path),
      ),
    );
  } catch (e) {
  // If an error occurs, log the error to the console.
  print(e);
  }

}
class cameraDecision extends StatelessWidget{
  final String imagePath;
  cameraDecision({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(imagePath);
    final File imageFile = File(imagePath);
    final FirebaseVisionImage vis_image = FirebaseVisionImage.fromFile(imageFile);
    labelImage(vis_image, context);


    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image
      body: Image.file(File(imagePath)),
    );
  }
}

Future<Null> labelImage(FirebaseVisionImage image, BuildContext context) async{
  final ImageLabeler labeler = FirebaseVision.instance.cloudImageLabeler();
  final List<ImageLabel> labels = await labeler.processImage(image);

//  FirebaseDatabase database = new FirebaseDatabase();
  var reference = FirebaseDatabase.instance.reference();
  reference.child('food').once().then((DataSnapshot snapshot){

    Map<dynamic, dynamic> values = snapshot.value;
    values.forEach((key, values) {
     for(var i = 0; i < labels.length; i++){
       if (labels[i].text.toLowerCase() == key.toString()) {
        var newEntry = reference.child('history').push();
//        print(labels[i]);
        newEntry.update({
          "food" : key.toString(),
          "date" : new DateTime.now().toString(),
          "calories" : values["calories"],
          "carbs" : values["carbs"],
          "fat": values["fat"],
          "protein" : values["protein"]
        });
        _showDialog(context, key.toString() + " identified!");
//        print('updating');
       }
     }
    });
  });

}
class historyWidget extends StatelessWidget {
  final targetMap = <String>{};
  var calMap = Map();
  var fatMap = Map();
  var carbMap = Map();
  var proteinMap = Map();

  var totalProtein = 0;
  var totalFat = 0;
  var totalCarbs = 0;

  @override
  Widget build(BuildContext context) {
    var reference = FirebaseDatabase.instance.reference();
    reference.child('history').once().then((DataSnapshot snapshot){

      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        targetMap.add(values["food"]);
        print(targetMap.length);
      });
    });
  print(targetMap.length);
  var children = <Widget>[];
  for(int i=0; i< targetMap.length; i++){
  children.add(new ListTile(
  title: new Text(targetMap.elementAt(i))
  ));
  }
  return new ListView(
  children: children,
  );
  }

  readProtein() {
    var reference = FirebaseDatabase.instance.reference();
    reference.child('food').once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        this.proteinMap[values["food"]] = values["Protein"];
      });
    });
  }

  readCarbs() {
    var reference = FirebaseDatabase.instance.reference();
    reference.child('food').once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        this.carbMap[values["food"]] = values["carbs"];
      });
    });
  }

  readFat() {
    var reference = FirebaseDatabase.instance.reference();
    reference.child('food').once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        this.fatMap[values["food"]] = values["fat"];
      });
    });
  }


  readCals() {
    var reference = FirebaseDatabase.instance.reference();
    reference.child('food').once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        this.calMap[values["food"]] = values["calories"];
      });
    });
  }
}
Future<Null> _restartCamera(CameraDescription description) async {
    final CameraController tempController = _controller;
    _controller = null;
    await tempController?.dispose();
    _controller = new CameraController(description, ResolutionPreset.high);
    await _controller.initialize();

}

Future<Null> flipCamera() async {
  if (_controller != null) {
    var newDescription = _cameras.firstWhere((desc) {
      return desc.lensDirection != _controller.description.lensDirection;
    });

    await _restartCamera(newDescription);
  }
}

class CameraIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (_controller != null) {
      return new Icon(
        _cameraLensIcon(_controller.description.lensDirection),
        color: Colors.white,
      );
    } else {
      return new Container();
    }
  }
}

// user defined function
void _showDialog(BuildContext context, String message) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: new Text("Item Tracked!"),
        content: new Text(message),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class CameraHome extends StatefulWidget {
  @override
  _CameraHomeState createState() => new _CameraHomeState();
}

class _CameraHomeState extends State<CameraHome> with WidgetsBindingObserver {
  bool opening = false;
  String imagePath;
  int pictureCount = 0;

  @override
  void initState() {

    super.initState();
    WidgetsBinding.instance.addObserver(this);

    availableCameras().then((cams) {
      _cameras = cams;
//      _cameras[1].lensDirection = CameraLensDirection.back;
      _controller = new CameraController(_cameras[0], ResolutionPreset.high);
      _controller.initialize()
        .then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
    });

  }

  @override
  void dispose() {
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      var description = _cameras.firstWhere((desc) {
        return desc.lensDirection == _controller.description.lensDirection;
      });

      _restartCamera(description)
        .then((_) { 
          setState(() {});
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenDimension = MediaQuery.of(context).size;
    final List<Widget> columnChildren = <Widget>[];

    if (_controller != null && _controller.value.isInitialized) {
      columnChildren.add(new Expanded(
        child: new FittedBox(
          fit: BoxFit.fitHeight,
          alignment: AlignmentDirectional.center,
          child: new Container(
            width: screenDimension.width,
            height: screenDimension.height * _controller.value.aspectRatio,
            child: new CameraPreview(_controller),
          )
        )
      ));
    } else {
      columnChildren.add(new Center(
        child: new Directionality(
          textDirection: TextDirection.ltr,
          child: new Icon(Icons.question_answer)
        )
      ));
    }

    return new Column(
      children: columnChildren,
    );
  }
}

