import 'package:flutter/material.dart';

class CustomeAlertDialog extends StatelessWidget {
  final BuildContext context;
  final String title;
  final String message;

  CustomeAlertDialog({
    @required this.context,
    this.title,
    @required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text((title == null) ? 'Error!' : title),
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
