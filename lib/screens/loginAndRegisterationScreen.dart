import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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

  // void _trySubmit() {
  //   final isValid = _formKey.currentState.validate();
  //   FocusScope.of(context).unfocus();

  //   if (isValid) {
  //     _formKey.currentState.save();
  //     widget.submitFn(
  //       _userEmail.trim(),
  //       _userName.trim(),
  //       _userPassword.trim(),
  //       _isLogin,
  //       context,
  //     );
  //   }
  // }

  void _googleSignIn() {
    //LOGIN USING GOOGLE HERE
    authService.googleMethodAuth().then((user) {
      if (user == null) {
        //Login failed
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

  void _normalSignIn() {
    //LOGIN USING EMAIL HERE
    authService
        .normalMethodAuthWithEmail(_userEmail, _userPassword, _isLogin)
        .then((user) {
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
          title: Text(_isLogin ? 'Login' : 'Register'),
        ),
        body: Center(
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
                        ),
                        validator: (value) {
                          return (value.isEmpty || !value.contains('@'))
                              ? 'Please enter valid email'
                              : null;
                        },
                        onSaved: (value) {
                          _userEmail = value;
                        },
                      ),
                      TextFormField(
                        key: ValueKey('password'),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                        ),
                        validator: (value) {
                          return (value.isEmpty || value.length < 6)
                              ? 'Password must be atleast 6 characters long'
                              : null;
                        },
                        onSaved: (value) {
                          _userPassword = value;
                        },
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      RaisedButton(
                        child: Text(_isLogin ? 'Login' : 'Signup'),
                        onPressed: _normalSignIn,
                      ),
                      RaisedButton(
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
                              Text(_isLogin
                                  ? 'Login in using google account'
                                  : 'Signup in using google account'),
                            ],
                          ),
                        ),
                        onPressed: _googleSignIn,
                      ),
                      FlatButton(
                        child: Text(_isLogin
                            ? 'Create new account'
                            : 'I already have an account'),
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
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
    );
  }
}
