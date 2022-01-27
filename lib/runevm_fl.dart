import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const capabilitiesDefinition = {
  1: "RandCapability",
  2: "AudioCapability",
  3: "AccelCapability",
  4: "ImageCapability",
  5: "RawCapability"
};

class RunevmFl {
  static const MethodChannel _channel = const MethodChannel('runevm_fl');

  static Future<bool?> load(Uint8List bytes) async {
    await _channel.invokeMethod('load', bytes);

    return true;
  }

  static Future<List<dynamic>> getLogs() async {
    if (!kIsWeb) {
      if (Platform.isIOS) {
        List<dynamic> reply = await _channel.invokeMethod('getLogs');
        return reply;
      } else {
        String reply = await _channel.invokeMethod('getLogs');
        List<String> splittedReply = reply.split("\n");
        if (splittedReply.length > 0) {
          splittedReply.removeLast();
        }

        return splittedReply;
      }
    } else {
      List<dynamic> reply = await _channel.invokeMethod('getLogs');
      return reply;
    }
  }

  static Future<dynamic> get manifest async {
    dynamic reply = await _channel.invokeMethod('getManifest');
    if (!kIsWeb) {
      if (Platform.isIOS) {
        reply = utf8.decode(List<int>.from(reply));
      }
      List<dynamic> capabilities = jsonDecode(reply);
      //[{"capability":4,"parameters":[{"key":"pixel_format","value":"0"},{"key":"width","value":"384"},{"key":"height","value":"384"}]},{"capability":4,"parameters":[{"key":"pixel_format","value":"0"},{"key":"width","value":"256"},{"key":"height","value":"256"}]}]
      // to
      // [{"type":"ImageCapability","width":96,"pixel_format":2,"height":96}]

      List manifest = [];
      for (dynamic element in capabilities) {
        Map<String, dynamic> cap = {
          "type": capabilitiesDefinition[element["capability"]]
        };
        for (dynamic param in element["parameters"]) {
          cap[param["key"]] = int.tryParse("${param["value"]}");
        }
        manifest.add(cap);
      }
      return manifest;
    }
    return jsonDecode(reply);
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
