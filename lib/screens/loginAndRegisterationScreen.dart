import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'splashScreen.dart';
import 'homeScreen.dart';
import '../widgets/customeAlertDialog.dart';

//==================This is the Login Screen for the app==================

class LoginAndRegisterationScreen extends StatefulWidget {
  @override
  _LoginAndRegisterationScreenState createState() =>
      new _LoginAndRegisterationScreenState();
}

class _LoginAndRegisterationScreenState
    extends State<LoginAndRegisterationScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _userEmail = '';
  var _userPassword = '';
  var _obscureText = true;
  var _isAPIDone = true;

  String _validateEmail(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return 'Email can\'t be empty';
    } else if (!value.contains(RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))) {
      return 'Enter a correct email address';
    }

    return null;
  }

  String _validatePassword(String value) {
    value = value.trim();

    String compinedReg =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[_!@#\$%\^&\*])(?=.{6,})';
    String smallReg = r'^(?=.*[a-z])';
    String capitalReg = r'^(?=.*[A-Z])';
    String charReg = r'^(?=.*[_!@#\$%\^&\*])';
    String numberReg = r'^(?=.*[0-9])';

    if (value.isEmpty) {
      return 'Password can\'t be empty';
    } else if (!value.contains(RegExp(compinedReg))) {
      String resultError = 'Enter a correct password:';

      if (!value.contains(RegExp(smallReg))) {
        resultError += '\n' + 'Atleat 1 small letter';
      }

      if (!value.contains(RegExp(capitalReg))) {
        resultError += '\n' + 'Atleat 1 capital letter';
      }

      if (!value.contains(RegExp(charReg))) {
        resultError += '\n' + 'Atleat 1 character';
      }

      if (!value.contains(RegExp(numberReg))) {
        resultError += '\n' + 'Atleat 1 number';
      }

      if (value.length < 6) {
        resultError += '\n' + 'Not less than 6 characters';
      }

      return resultError;
    }

    return null;
  }

  void _togglePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool _clearToAuth() {
    FocusScope.of(context).unfocus();
    return _formKey.currentState.validate();
  }

  //LOGIN USING GOOGLE HERE
  void _googleSignIn() {
    authService.googleMethodAuth().then((user) {
      if (user == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomeAlertDialog(
              context: context,
              message:
                  'Please make sure your Google Account is usable. Also make sure that you have a active internet connection, and try again.',
            );
          },
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });
  }

  //LOGIN USING EMAIL HERE
  void _normalSignIn() {
    setState(() {
      _isAPIDone = false;
    });

    authService
        .normalMethodAuthWithEmail(
            _userEmail.trim(), _userPassword.trim(), _isLogin)
        .whenComplete(() {
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
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Intercom',
            style: TextStyle(fontSize: 35),
          ),
        ),
        body: Center(
          child: !_isAPIDone
              ? SpinKitChasingDots(color: Colors.blue, size: 50.0)
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
                                    return _validateEmail(value);
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                    return _validatePassword(value);
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
                                      shape:
                                          Theme.of(context).buttonTheme.shape,
                                      child: Text('Login'),
                                      onPressed: () {
                                        if (_clearToAuth()) {
                                          _isLogin = true;
                                          _normalSignIn();
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    RaisedButton(
                                      color: Theme.of(context).accentColor,
                                      shape:
                                          Theme.of(context).buttonTheme.shape,
                                      child: Text('Signup'),
                                      onPressed: () {
                                        if (_clearToAuth()) {
                                          _isLogin = false;
                                          _normalSignIn();
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image(
                                          image: AssetImage(
                                              'assets/google_logo.png'),
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
