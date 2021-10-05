import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class RunevmFl {
  static const MethodChannel _channel = const MethodChannel('runevm_fl');

  static Future<bool?> load(Uint8List bytes) async {
    print("invoking");
    print(await _channel.invokeMethod('load', bytes));
    return true;
  }

  static Future<dynamic> get manifest async {
    final dynamic reply = await _channel.invokeMethod('getManifest');
    return reply;
  }

  static Future<dynamic> runRune(Uint8List input,
      [List<int> lengths = const []]) async {
    if (lengths.length == 0) {
      lengths = [input.length];
    }
    final dynamic result = await _channel
        .invokeMethod('runRune', {"bytes": input, "lengths": lengths});
    return result;
  }
}
