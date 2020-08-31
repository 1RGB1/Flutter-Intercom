import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../services/firebaseManager.dart';
import 'loginAndRegisterationScreen.dart';
import 'homeScreen.dart';

FirebaseManager firebaseManager;

class SplachScreen extends StatefulWidget {
  SplachScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SplachScreenState createState() => _SplachScreenState();
}

class _SplachScreenState extends State<SplachScreen> {
  void initState() {
    Firebase.initializeApp();
    firebaseManager = FirebaseManager(context);
    firebaseManager.getBuildingName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Intercom',
          style: TextStyle(fontSize: 35),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Welcome to Intercom',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: (kIsWeb) ? 50 : 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void mainNavigationPage(BuildContext context) {
  Future.delayed(new Duration(seconds: 3)).whenComplete(() {
    if (blIsSignedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginAndRegisterationScreen(),
        ),
      );
    }
  });
}
