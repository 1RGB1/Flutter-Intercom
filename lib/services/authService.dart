import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as MobFirebaseFirestore;
import 'package:firebase/firebase.dart' as WebFirebase;
import 'package:firebase/firestore.dart' as WebFirestore;
import 'package:firebase_auth/firebase_auth.dart' as MobFirebaseAuth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../screens/splashScreen.dart';

MobFirebaseAuth.User firebaseUser;
WebFirebase.User webFirebaseUser;
//For storing user Profile info
Map<String, dynamic> userProfile = new Map();

//This is the main Firebase auth object
MobFirebaseAuth.FirebaseAuth mobAuth = MobFirebaseAuth.FirebaseAuth.instance;
WebFirebase.Auth webAuth = WebFirebase.auth();

// For google sign in
final GoogleSignIn mobGoogleSignIn = GoogleSignIn();
WebFirebase.GoogleAuthProvider webGoogleSignIn;

//CloudFireStore
MobFirebaseFirestore.FirebaseFirestore dbFirestore =
    MobFirebaseFirestore.FirebaseFirestore.instance;
WebFirestore.Firestore webFirestore = WebFirebase.firestore();

BuildContext _context;
bool blIsSignedIn = false;

class AuthService {
  AuthService(BuildContext ctx) {
    _context = ctx;
    checkIsSignedIn().then((_blIsSignedIn) {
      mainNavigationPage(ctx);
    });
  }

  //Checks if the user has signed in
  Future<bool> checkIsSignedIn() async {
    if (!kIsWeb) {
      //For mobile
      if (mobAuth != null && (await mobGoogleSignIn.isSignedIn())) {
        firebaseUser = mobAuth.currentUser;
        blIsSignedIn = (firebaseUser != null) ? true : false;
      } else {
        blIsSignedIn = false;
      }
    } else {
      //For web
      if (webAuth != null) {
        webFirebaseUser = await webAuth.onAuthStateChanged.first;
        blIsSignedIn = (webFirebaseUser != null) ? true : false;
      } else {
        blIsSignedIn = false;
      }
    }
    return blIsSignedIn;
  }

  //Log in using google
  Future<dynamic> googleMethodAuth() async {
    try {
      GoogleSignInAccount googleUser = await mobGoogleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      MobFirebaseAuth.UserCredential signinCredential =
          await mobAuth.signInWithCredential(credential);
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
      final MobFirebaseAuth.UserCredential credential = await mobAuth
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
      final MobFirebaseAuth.UserCredential credential = await mobAuth
          .signInWithEmailAndPassword(email: email, password: password);
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
    if (!kIsWeb) {
      //For mobile
      dbFirestore
          .collection("Master")
          .doc(firebaseUser.email)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.data() != null) {
          userProfile = snapshot.data();
        }
      });
    } else {
      //For Web
      webFirestore
          .collection("Master")
          .doc(webFirebaseUser.email)
          .onSnapshot
          .listen((snapshot) {
        if (snapshot.data != null) {
          userProfile = snapshot.data();
        }
      });
    }
  }

  //Update the data into the database
  Future<bool> setData() async {
    bool blReturn = false;
    if (!kIsWeb) {
      //For mobile
      await dbFirestore
          .collection('Master')
          .doc(firebaseUser.email)
          .set(userProfile)
          .then((onValue) async {
        blReturn = true;
      });
    } else {
      //For Web
      await webFirestore
          .collection('Master')
          .doc(webFirebaseUser.email)
          .set(userProfile)
          .then((onValue) async {
        blReturn = true;
      });
    }
    return blReturn;
  }

  //Signout using normal method
  void signOut() async {
    if (!kIsWeb) {
      //For mobile
      mobAuth.signOut();
    } else {
      //For web
      webAuth.signOut();
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', false);
  }

  //Signout using google method
  void googleSignOut() async {
    await mobGoogleSignIn.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', false);
  }
}
