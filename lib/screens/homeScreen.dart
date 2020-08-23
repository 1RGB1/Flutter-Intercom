import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'splashScreen.dart';
import 'loginAndRegisterationScreen.dart';
//==================This is the Homepage for the app==================s

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _isDoorClosed = true;
  var _openCloseButtonText = 'Open';
  var _openCloseButtonColor = Colors.deepPurple;
  Timer _timer;
  var _time = 10;

  @override
  void initState() {
    //loadUserData();
    super.initState();
  }

  @override
  void dispose() {
    _endTime();
    super.dispose();
  }

  //Loads user data
  Future<void> loadUserData() async {
    //Get the data from firestore
    await authService.getData();
    //Not setState, to reflect the changes of Map to the widget tree
    setState(() {});
  }

  void _openCloseAction() {
    setState(() {
      _isDoorClosed = !_isDoorClosed;
      if (_isDoorClosed) {
        _endTime();
      } else {
        _startTime();
      }
      _toggleOpenCloseButton();
    });
  }

  void _toggleOpenCloseButton() {
    _openCloseButtonColor = (_isDoorClosed) ? Colors.deepPurple : Colors.red;
    _openCloseButtonText = (_isDoorClosed) ? 'Open' : 'Close';
  }

  void _startTime() {
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) => setState(
        () {
          if (_time < 1) {
            _endTime();
          } else {
            _time -= 1;
          }
        },
      ),
    );
  }

  void _endTime() {
    _timer.cancel();
    _time = 10;
    _isDoorClosed = true;
    _toggleOpenCloseButton();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
                  fontSize: 35,
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Building 406',
                  style: TextStyle(
                    fontSize: (kIsWeb) ? 65 : 35,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Door Control',
                  style: TextStyle(
                    fontSize: (kIsWeb) ? 55 : 25,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Closed',
                  style: TextStyle(
                    fontSize: (kIsWeb) ? 55 : 25,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  (!_isDoorClosed && _time >= 1) ? '$_time' : '',
                  style: TextStyle(
                    fontSize: (kIsWeb) ? 45 : 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              RaisedButton(
                color: _openCloseButtonColor,
                shape: Theme.of(context).buttonTheme.shape,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    _openCloseButtonText,
                    style: TextStyle(
                      fontSize: (kIsWeb) ? 35 : 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                onPressed: _openCloseAction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
