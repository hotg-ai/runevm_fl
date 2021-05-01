import 'dart:async';
import 'dart:typed_data';
import 'hammerd.dart';
import 'package:flutter/services.dart';

class RunevmFl {
  static const MethodChannel _channel = const MethodChannel('runevm_fl');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool?> loadWASM(Uint8List bytes) async {
    final bool? reply = await _channel.invokeMethod('loadWASM', bytes);
    return reply;
  }

  static Future<dynamic> get manifest async {
    final dynamic reply = await _channel.invokeMethod('getManifest');
    return reply;
  }

  static Future<String?> runRune(Uint8List input) async {
    final String? result = await _channel.invokeMethod('runRune', input);
    return result;
  }
}
