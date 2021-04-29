import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:runevm_fl/runevm_fl.dart';

import '2048/home_mobile.dart' if (dart.library.js) '2048/home_web.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    /*String platformVersion = "none";
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      ByteData bytes = await rootBundle.load('assets/microspeech.rune');
      bool loaded =
          await RunevmFl.loadWASM(bytes.buffer.asUint8List()) ?? false;
      if (loaded) {
        platformVersion = (await RunevmFl.manifest).toString();
      }
      var list = new List<int>.generate(32000, (i) => 0);
      String? output = await RunevmFl.runRune(Uint8List.fromList(list));
      print("Rune Output: $output");
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      print("RuneVM: $_platformVersion");
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}
