import 'package:flutter/material.dart';

class UserModel {
  String email;
  String flatNumber;
  bool isDoorClosed;
  String username;
  String password;
  String lastOpendDate;

  UserModel({
    @required this.email,
    @required this.flatNumber,
    @required this.isDoorClosed,
    this.username,
    this.password,
    this.lastOpendDate,
  });
}
