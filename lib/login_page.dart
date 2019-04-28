//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum FormMode { LOGIN, SIGNUP }

class LoginPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() =>
      new
      _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Login"),
      ),
      body: Stack(
        children: <Widget>[
          _showBody(),
          _showCircularProgress(),
        ],
      ),
    );
  }
}

Widget _showCircularProgress(){
//  if (_isLoading){
//    return Center(child: CircularProgressIndicator());
//  }
  return Container(height: 0.0, width: 0.0,);
}

Widget _showLogo() {
  return new Hero(
    tag: 'hero',
    child: Padding(
      padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Text('Icon'),
      ),
    ),
  );
}

Widget _showBody(){
  return new Container(
      padding: EdgeInsets.all(16.0),
      child: new Form(
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            Text('1'),
            Text('2'),
          ],
        ),
      ));
}
