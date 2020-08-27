import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_intercom/models/userModel.dart';
import 'package:flutter_intercom/services/firebaseManager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/foundation.dart';

import 'splashScreen.dart';
import 'homeScreen.dart';
import '../widgets/customeAlertDialog.dart';
import '../util/validator.dart';

//==================This is the Login Screen for the app==================

class LoginAndRegisterationScreen extends StatefulWidget {
  @override
  _LoginAndRegisterationScreenState createState() => new _LoginAndRegisterationScreenState();
}

class _LoginAndRegisterationScreenState extends State<LoginAndRegisterationScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  UserModel _userModel;
  String _userEmail;
  String _userPassword;
  var _obscureText = true;
  var _isAPIDone = true;

  void _togglePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool _clearToAuth() {
    FocusScope.of(context).unfocus();
    return _formKey.currentState.validate();
  }

  _getUserFromFirebase() async {
    await firebaseManager.getUserData((_userEmail != null) ? _userEmail.trim() : null);
  }

  UserModel _getUserModel() {
    if (userModel != null) {
      return userModel;
    } else {
      return UserModel(
        email: (_userEmail != null) ? _userEmail.trim() : null,
        flatNumber: null,
        isDoorClosed: true,
        password: (_userPassword != null) ? _userPassword.trim() : null,
        username: null,
      );
    }
  }

  //LOGIN USING GOOGLE HERE
  void _googleSignIn() {
    firebaseManager.googleMethodAuth().then((user) {
      if (user == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomeAlertDialog(
              context: context,
              title: 'Failed to log in!',
              message:
                  'Please make sure your Google Account is usable. Also make sure that you have a active internet connection, and try again.',
            );
          },
        );
      } else {
        Future.delayed(Duration(seconds: 3)).whenComplete(() {
          _userEmail = firebaseManager.getUserEmailFromGoogle();
          _userModel = _getUserModel();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        });
      }
    });
  }

  //LOGIN USING EMAIL HERE
  void _normalSignIn() {
    setState(() {
      _isAPIDone = false;
    });

    firebaseManager.normalMethodAuthWithEmail(_userModel, _isLogin).whenComplete(() {
      setState(() {
        _isAPIDone = true;
      });
    }).then((user) {
      if (user == null) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomeAlertDialog(
                context: context,
                title: 'Failed to log in!',
                message:
                    'Please make sure your Account is usable. Also make sure that you have a active internet connection, and try again.',
              );
            });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Intercom',
            style: TextStyle(fontSize: 35),
          ),
        ),
        body: Center(
          child: !_isAPIDone
              ? SpinKitWave(color: Colors.blue, size: 50.0)
              : Container(
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
                                  key: ValueKey('email'),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email address',
                                    hintText: 'example@example.example',
                                  ),
                                  validator: (value) {
                                    return Validator.validateEmail(value);
                                  },
                                  onSaved: (value) {
                                    _userEmail = value;
                                  },
                                  onChanged: (value) {
                                    _userEmail = value;
                                  },
                                ),
                                TextFormField(
                                  key: ValueKey('password'),
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    suffixIcon: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(!_obscureText
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                          onPressed: _togglePassword,
                                        ),
                                        Icon(Icons.lock),
                                      ],
                                    ),
                                  ),
                                  validator: (value) {
                                    return Validator.validatePassword(value);
                                  },
                                  onSaved: (value) {
                                    _userPassword = value;
                                  },
                                  onChanged: (value) {
                                    _userPassword = value;
                                  },
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    RaisedButton(
                                      color: Theme.of(context).accentColor,
                                      shape: Theme.of(context).buttonTheme.shape,
                                      child: Text('Login'),
                                      onPressed: () async {
                                        if (_clearToAuth()) {
                                          await _getUserFromFirebase();
                                          Future.delayed(Duration(seconds: 2)).whenComplete(() {
                                            _userModel = _getUserModel();
                                            _isLogin = true;
                                            _normalSignIn();
                                          });
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    RaisedButton(
                                      color: Theme.of(context).accentColor,
                                      shape: Theme.of(context).buttonTheme.shape,
                                      child: Text('Signup'),
                                      onPressed: () async {
                                        if (_clearToAuth()) {
                                          await _getUserFromFirebase();
                                          Future.delayed(Duration(seconds: 2)).whenComplete(() {
                                            _userModel = _getUserModel();
                                            _isLogin = false;
                                            _normalSignIn();
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                RaisedButton(
                                  shape: Theme.of(context).buttonTheme.shape,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image(
                                          image: AssetImage('assets/google_logo.png'),
                                          height: 25,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text('Use google account'),
                                      ],
                                    ),
                                  ),
                                  onPressed: _googleSignIn,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
