// @dart=2.9
import 'package:flutter/material.dart';
import 'package:runevm_fl/runevm_fl_web.dart';
import 'dart:async';
import '2048/home_mobile.dart' if (dart.library.js) '2048/home_web.dart';
import 'package:runevm_fl/runevm_fl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    print(RunevmFl.getLogs());
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
