import 'package:flutter/material.dart';
import '../services/authService.dart';
import 'loginAndRegisterationScreen.dart';
import 'homeScreen.dart';

AuthService authService;

class SplachScreen extends StatefulWidget {
  SplachScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SplachScreenState createState() => _SplachScreenState();
}

class _SplachScreenState extends State<SplachScreen> {
  void initState() {
    authService = AuthService(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Intercom',
          style: TextStyle(fontSize: 35),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Intercom",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.05)),
            )
          ],
        ),
      ),
    );
  }
}

void mainNavigationPage(BuildContext context) {
  if (blIsSignedIn) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginAndRegisterationScreen()),
    );
  }
}
