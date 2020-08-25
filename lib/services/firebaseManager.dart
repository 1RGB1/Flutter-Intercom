import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_intercom/models/userModel.dart';
import 'package:flutter_intercom/util/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../screens/splashScreen.dart';
import '../util/constants.dart';

User firebaseUser;

Map<String, dynamic> _userProfile = new Map();

UserModel _userModel;

final FirebaseAuth _auth = FirebaseAuth.instance;

final GoogleSignIn _googleSignIn = GoogleSignIn();

FirebaseFirestore _dbFirestore = FirebaseFirestore.instance;

BuildContext _context;
bool blIsSignedIn = false;
DoorStatus doorStatus = DoorStatus.closed;
int doorDelay = 0;

class FirebaseManager {
  FirebaseManager(BuildContext ctx) {
    _context = ctx;
    checkIsSignedIn().then((_blIsSignedIn) {
      mainNavigationPage(_context, _userModel);
    });
  }

  //Checks if the user has signed in
  Future<bool> checkIsSignedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool authSignedIn = prefs.getBool('auth') ?? false;

    if (!authSignedIn) {
      blIsSignedIn = false;
    } else {
      if (_auth != null && ((await _googleSignIn.isSignedIn()) || (_auth.currentUser != null))) {
        firebaseUser = _auth.currentUser;
        _userModel = await getUserData(firebaseUser.email);
        blIsSignedIn = (firebaseUser != null) ? true : false;
      } else {
        blIsSignedIn = false;
      }
    }
    return blIsSignedIn;
  }

  //Log in using google
  Future<dynamic> googleMethodAuth() async {
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential signinCredential = await _auth.signInWithCredential(credential);
      firebaseUser = signinCredential.user;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('auth', true);
    } on PlatformException catch (error) {
      var message = (error.message != null)
          ? error.message
          : 'An error occured, please check your credentials';

      Scaffold.of(_context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(_context).errorColor,
        ),
      );
    } catch (error) {
      print(error);
    }

    return firebaseUser;
  }

  //Login or Register using normal method authentication
  Future<dynamic> normalMethodAuthWithEmail(UserModel userModel, bool isLogin) async {
    User user = (isLogin)
        ? await _loginWithEmailAndPassword(userModel.email, userModel.password)
        : await _registerWithEmailAndPassword(userModel.email, userModel.password);

    if (user != null) {
      setUserData(userModel);
    }

    return user;
  }

  //Register using email and password
  Future<dynamic> _registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      firebaseUser = credential.user;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('auth', true);
    } on PlatformException catch (error) {
      var message = (error.message != null)
          ? error.message
          : 'An error occured, please check your credentials';

      Scaffold.of(_context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(_context).errorColor,
        ),
      );
    } catch (error) {
      print(error);
    }
    return firebaseUser;
  }

  //Login using email and password
  Future<dynamic> _loginWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential credential =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      firebaseUser = credential.user;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('auth', true);
    } on PlatformException catch (error) {
      var message = (error.message != null)
          ? error.message
          : 'An error occured, please check your credentials';

      Scaffold.of(_context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(_context).errorColor,
        ),
      );
    } catch (error) {
      print(error);
    }
    return firebaseUser;
  }

  //Gets the userData
  Future<UserModel> getUserData(String userEmail) async {
    UserModel userModel;

    _dbFirestore.collection('users').doc(userEmail).snapshots().listen((snapshot) async {
      if (snapshot.data() != null) {
        _userProfile = snapshot.data();
        userModel = Utilities.userProfileToUserModelMapping(_userProfile);
      }
    });
    return userModel;
  }

  //Update the data into the database
  Future<bool> setUserData(UserModel user) async {
    bool blReturn = false;

    _userProfile = {
      'flat_number': user.flatNumber,
      'isDoorClosed': user.isDoorClosed,
      'password': user.password,
      'username': user.username,
      'last_opend': FieldValue.serverTimestamp(),
    };

    await _dbFirestore.collection('users').doc(user.email).set(_userProfile).then((onValue) async {
      blReturn = true;
    });
    return blReturn;
  }

  //Get door status
  getDoorStatus() async {
    _dbFirestore
        .collection('door')
        .doc('zFT2snwlzAUGI1h1RBOg')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.data() != null) {
        doorStatus = snapshot.data()['status'];
      }
    });
    doorStatus = DoorStatus.closed;
  }

  //Get door status
  Future<void> setDoorStatus(bool isClosed) async {
    _dbFirestore
        .collection('door')
        .doc('zFT2snwlzAUGI1h1RBOg')
        .set(<String, dynamic>{'status': isClosed});
  }

  //Get door delay time
  Future<int> getDoorDelay() async {
    _dbFirestore
        .collection('delay')
        .doc('DLIeVPfBEoxLDo5qihJA')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.data() != null) {
        doorDelay = snapshot.data()['door_delay'];
        return doorDelay;
      }
    });
    doorDelay = 0;
    return doorDelay;
  }

  //Signout using normal method
  void signOut() async {
    _auth.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', false);
    prefs.setString('email', null);
  }

  //Signout using google method
  void googleSignOut() async {
    await _googleSignIn.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', false);
  }
}
