import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';


final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

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
      padding: EdgeInsets.fromLTRB(0.0, 200.0, 0.0, 0.0),
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
            _showTitle(),
            _showEmailInput(),
            _showPasswordInput(),
            _showButton()
          ],
        ),
      ));
}

Widget _showEmailInput() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
    child: new TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: new InputDecoration(
          hintText: 'gmail',
          icon: new Icon(
            Icons.mail,
            color: Colors.grey,
          )),
//      validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
//      onSaved: (value) => _email = value,
    ),
  );
}

Widget _showTitle(){
  return Padding(
    padding: const EdgeInsets.fromLTRB(0.0, 200.0, 0.0, 0.0),
    child: new Text(
        'NutriSnap',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 52)
      ,
    )
  );
}

Widget _showPasswordInput() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
    child: new TextFormField(
      maxLines: 1,
      obscureText: true,
      autofocus: false,
      decoration: new InputDecoration(
          hintText: 'password',
          icon: new Icon(
            Icons.lock,
            color: Colors.grey,
          )),
      validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
      onSaved: (value) => _password = value,
    ),
  );
}

Widget _showButton() {
  return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new FloatingActionButton.extended(
        icon: Image.asset('assets/google_g_logo.png', height: 24.0),
        label: const Text('Sign in with Google'),
      )
  );
}

Widget _attemptSignIn(){

}

Future<FirebaseUser> _handleSignIn() async {
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
  );

  final FirebaseUser user = await _auth.signInWithCredential(credential);
  print("signed in " + user.displayName);
  return user;
}
