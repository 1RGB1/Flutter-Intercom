import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../screens/splashScreen.dart';

User firebaseUser;
//For storing user Profile info
Map<String, dynamic> userProfile = new Map();

//This is the main Firebase auth object
FirebaseAuth _auth = FirebaseAuth.instance;

// For google sign in
final GoogleSignIn _googleSignIn = GoogleSignIn();

//CloudFireStore
FirebaseFirestore _dbFirestore = FirebaseFirestore.instance;

BuildContext _context;
bool blIsSignedIn = false;

class AuthService {
  AuthService(BuildContext ctx) {
    _context = ctx;
    checkIsSignedIn().then((_blIsSignedIn) {
      mainNavigationPage(_context);
    });
  }

  //Checks if the user has signed in
  Future<bool> checkIsSignedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool authSignedIn = prefs.getBool('auth') ?? false;

    if (!authSignedIn) {
      blIsSignedIn = false;
    } else {
      if (_auth != null &&
          ((await _googleSignIn.isSignedIn()) || (_auth.currentUser != null))) {
        firebaseUser = _auth.currentUser;
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
      UserCredential signinCredential =
          await _auth.signInWithCredential(credential);
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
  Future<dynamic> normalMethodAuthWithEmail(
      String email, String password, bool isLogin) async {
    return (isLogin)
        ? await _loginWithEmailAndPassword(email, password)
        : await _registerWithEmailAndPassword(email, password);
  }

  //Register using email and password
  Future<dynamic> _registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
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
  Future<dynamic> _loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
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
  getData() async {
    _dbFirestore
        .collection("Master")
        .doc(firebaseUser.email)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.data() != null) {
        userProfile = snapshot.data();
      }
    });
  }

  //Update the data into the database
  Future<bool> setData() async {
    bool blReturn = false;
    await _dbFirestore
        .collection('Master')
        .doc(firebaseUser.email)
        .set(userProfile)
        .then((onValue) async {
      blReturn = true;
    });
    return blReturn;
  }

  //Signout using normal method
  void signOut() async {
    _auth.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', false);
  }

  //Signout using google method
  void googleSignOut() async {
    await _googleSignIn.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', false);
  }
}
