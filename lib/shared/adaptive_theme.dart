import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

final ThemeData _androidTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Caviar',
    primarySwatch: Colors.blueGrey,
    accentColor: Colors.deepOrange,
    backgroundColor: Colors.black,
    buttonColor: Colors.amber);

final ThemeData _iOSTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Caviar',
    primarySwatch: Colors.lightBlue.shade800,
    accentColor: Colors.grey,
    backgroundColor: Colors.black,
    buttonColor: Colors.amber);

ThemeData getAdaptiveTheme(context) {
  return Theme.of(context).platform == TargetPlatform.iOS
      ? _iOSTheme
      : _androidTheme;
}
