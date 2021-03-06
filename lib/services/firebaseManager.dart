import 'dart:async';

import 'package:flutter/foundation.dart';
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

UserModel userModel;

final GoogleSignIn _googleSignIn = GoogleSignIn();

FirebaseFirestore _dbFirestore = FirebaseFirestore.instance;

BuildContext _context;
bool blIsSignedIn = false;
DoorStatus doorStatus = DoorStatus.closed;
int doorDelay = 0;
String buildingName = '';

class FirebaseManager {
  FirebaseManager(BuildContext ctx) {
    _context = ctx;
    checkIsSignedIn().then((_blIsSignedIn) {
      mainNavigationPage(_context);
    });
  }

  //Checks if the user has signed in
  Future<bool> checkIsSignedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool authSignedIn = prefs.getBool('auth') ?? false;
    String userEmail = prefs.getString('userEmail');

    if (!authSignedIn || userEmail == null) {
      blIsSignedIn = false;
    } else {
      if (kIsWeb) {
        await getUserData(userEmail);
        blIsSignedIn = true;
      } else {
        if (FirebaseAuth.instance != null &&
            ((await _googleSignIn.isSignedIn()) || (FirebaseAuth.instance.currentUser != null))) {
          firebaseUser = FirebaseAuth.instance.currentUser;
          await getUserData(firebaseUser.email);
          blIsSignedIn = (firebaseUser != null) ? true : false;
        } else {
          blIsSignedIn = false;
        }
      }
    }
    return blIsSignedIn;
  }

  //Get user when using google method
  String getUserEmailFromGoogle() {
    return (_googleSignIn.currentUser != null) ? _googleSignIn.currentUser.email : null;
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
      UserCredential signinCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      firebaseUser = signinCredential.user;
      await getUserData(firebaseUser.email);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('auth', true);
      prefs.setString('userEmail', firebaseUser.email);
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
  Future<dynamic> normalMethodAuthWithEmail(UserModel model, bool isLogin) async {
    User user = (isLogin)
        ? await _loginWithEmailAndPassword(model.email, model.password)
        : await _registerWithEmailAndPassword(model.email, model.password);

    if (user != null && !isLogin) {
      setUserData(model);
      userModel = model;
    }

    return user;
  }

  //Register using email and password
  Future<dynamic> _registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      firebaseUser = credential.user;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('auth', true);
      prefs.setString('userEmail', email);
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
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      firebaseUser = credential.user;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('auth', true);
      prefs.setString('userEmail', email);
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
  getUserData(String userEmail) {
    Future.wait([
      _dbFirestore.collection('users').doc(userEmail).get().then((snapshot) {
        if (snapshot.data() != null) {
          _userProfile = snapshot.data();
          userModel = Utilities.userProfileToUserModelMapping(_userProfile);
          userModel.email = userEmail;
          return userModel;
        }
      })
    ]);
  }

  //Update the data into the database
  Future<bool> setUserData(UserModel user) async {
    bool blReturn = false;

    _userProfile = {
      'flat_number': user.flatNumber,
      'isDoorClosed': user.isDoorClosed,
      'password': user.password,
      'username': user.username,
      'last_opend': user.lastOpendDate,
    };

    await _dbFirestore.collection('users').doc(user.email).set(_userProfile).then((onValue) async {
      blReturn = true;
    });
    return blReturn;
  }

  //Get door status
  getDoorStatus() async {
    _dbFirestore
        .collection('building')
        .doc('7jDdH9Q4UsP06kDAyGN0')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.data() != null) {
        doorStatus = snapshot.data()['door_is_closed'] ? DoorStatus.closed : DoorStatus.closed;
      }
    });
  }

  //Get door status
  setDoorStatus(bool isClosed) async {
    _dbFirestore
        .collection('building')
        .doc('7jDdH9Q4UsP06kDAyGN0')
        .update(<String, dynamic>{'door_is_closed': isClosed});

    _getServerDate();
  }

  //Set server date
  _getServerDate() async {
    Future.wait([
      _dbFirestore
          .collection('serverTimeStamp')
          .doc('gf7LGjpwBsu33Cokpwxi')
          .set(<String, dynamic>{'createdAt': FieldValue.serverTimestamp()})
    ]).whenComplete(() {
      _dbFirestore
          .collection('serverTimeStamp')
          .doc('gf7LGjpwBsu33Cokpwxi')
          .snapshots()
          .listen((snapshot) async {
        if (snapshot.data() != null) {
          if (snapshot.data()['createdAt'] != null) {
            userModel.lastOpendDate = snapshot.data()['createdAt'].toDate().toIso8601String();
            setUserData(userModel);
          }
        }
      });
    });
  }

  //Get door delay time
  getDoorDelay() async {
    _dbFirestore
        .collection('building')
        .doc('7jDdH9Q4UsP06kDAyGN0')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.data() != null) {
        doorDelay = snapshot.data()['door_delay_time'];
      }
    });
  }

  //Get Building name
  getBuildingName() async {
    _dbFirestore
        .collection('building')
        .doc('7jDdH9Q4UsP06kDAyGN0')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.data() != null) {
        buildingName = snapshot.data()['name'];
      }
    });
  }

  //Signout using normal method
  void signOut() async {
    FirebaseAuth.instance.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', false);
    prefs.setString('userEmail', null);
  }

  //Signout using google method
  void googleSignOut() async {
    await _googleSignIn.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', false);
    prefs.setString('userEmail', null);
  }
}
