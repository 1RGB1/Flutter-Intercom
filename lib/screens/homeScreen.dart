import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_intercom/services/firebaseManager.dart';
import 'package:flutter_intercom/util/validator.dart';
import 'package:flutter_intercom/widgets/customeAlertDialog.dart';

import 'splashScreen.dart';
import 'loginAndRegisterationScreen.dart';
//==================This is the Homepage for the app==================s

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isInfoUpdated = false;
  var _isDoorClosed = true;
  var _openCloseButtonText = 'Open';
  var _openCloseButtonColor = Colors.deepPurple;
  Timer _timer;
  var _time = doorDelay;

  @override
  void initState() {
    firebaseManager.getDoorDelay();
    if (userModel != null) {
      _isInfoUpdated = (userModel.flatNumber != null) ? true : false;
    }
    super.initState();
  }

  @override
  void dispose() {
    _endTime();
    super.dispose();
  }

  bool _checkFieldsValidation() {
    FocusScope.of(context).unfocus();
    return _formKey.currentState.validate();
  }

  void _openCloseAction() {
    if (_isInfoUpdated) {
      setState(() {
        _time = doorDelay;
        _isDoorClosed = !_isDoorClosed;
        if (_isDoorClosed) {
          _endTime();
        } else {
          _startTime();
        }
        _toggleOpenCloseButton();
        firebaseManager.setDoorStatus(_isDoorClosed);
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomeAlertDialog(
            context: context,
            title: 'Error!',
            message: 'Please enter flat number and username first',
          );
        },
      );
    }
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
    if (_time != null) {
      _timer.cancel();
      _time = doorDelay;
    }
    _isDoorClosed = true;
    _toggleOpenCloseButton();
  }

  void _startIntercom() {
    firebaseManager.setUserData(userModel).then((isSuccess) {
      if (!isSuccess) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomeAlertDialog(
              context: context,
              title: 'Error!',
              message: 'Something went wrong',
            );
          },
        );
      } else {
        setState(() {
          _isInfoUpdated = true;
          _time = doorDelay;
        });
      }
    });
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
                  firebaseManager.signOut();
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginAndRegisterationScreen()));
                },
              ),
              Text(
                (userModel.username == null) ? 'Welcome' : userModel.username,
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
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (!_isInfoUpdated)
                Container(
                  width: 500,
                  child: Center(
                    child: Card(
                      margin: EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextFormField(
                                  key: ValueKey('username'),
                                  decoration: InputDecoration(
                                    labelText: 'User Name',
                                  ),
                                  validator: (value) {
                                    return Validator.validateUserName(value);
                                  },
                                  onSaved: (value) {
                                    userModel.username = value;
                                  },
                                  onChanged: (value) {
                                    userModel.username = value;
                                  },
                                ),
                                TextFormField(
                                  key: ValueKey('flatNumber'),
                                  decoration: InputDecoration(
                                    labelText: 'Flat Number',
                                  ),
                                  validator: (value) {
                                    return Validator.validateFlatNumber(value);
                                  },
                                  onSaved: (value) {
                                    userModel.flatNumber = value;
                                  },
                                  onChanged: (value) {
                                    userModel.flatNumber = value;
                                  },
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                RaisedButton(
                                  color: Theme.of(context).accentColor,
                                  shape: Theme.of(context).buttonTheme.shape,
                                  child: Text('Start Intercom'),
                                  onPressed: () {
                                    if (_checkFieldsValidation()) {
                                      _startIntercom();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Building $buildingName',
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
                  _openCloseButtonText,
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
