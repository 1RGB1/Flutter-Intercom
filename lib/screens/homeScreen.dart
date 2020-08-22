import 'package:flutter/material.dart';

import 'splashScreen.dart';
import 'loginAndRegisterationScreen.dart';
import '../services/authService.dart';
//==================This is the Homepage for the app==================s

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    loadUserData();
    super.initState();
  }

  //Loads user data
  Future<void> loadUserData() async {
    //Get the data from firestore
    await authService.getData();
    //Not setState, to reflect the changes of Map to the widget tree
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlatButton(
                child: Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onPressed: () {
                  authService.signOut();
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginAndRegisterationScreen()));
                },
              ),
              Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              Opacity(
                opacity: 0.0,
                child: Text(
                  'Welcome',
                ),
              ),
              // Text(
              //   'Welcome, ',
              // ),
              // Text(
              //   (firebaseUser.displayName != null)
              //       ? firebaseUser.displayName
              //       : firebaseUser.email,
              //   style: TextStyle(
              //     color: Colors.black,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
