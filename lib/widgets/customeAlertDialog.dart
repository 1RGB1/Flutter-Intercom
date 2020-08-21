import 'package:flutter/material.dart';

class CustomeAlertDialog extends StatelessWidget {
  final BuildContext context;
  final String message;

  CustomeAlertDialog({@required this.context, @required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Failed to log in!"),
      content: Text(this.message),
      actions: <Widget>[
        FlatButton(
          child: Text("Close"),
          onPressed: () {
            Navigator.of(this.context).pop();
          },
        ),
      ],
    );
  }
}
