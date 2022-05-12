import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const capabilitiesDefinitionString = {
  "RANDOM": "RandCapability",
  "SOUND": "AudioCapability",
  "ACCEL": "AccelCapability",
  "IMAGE": "ImageCapability",
  "RAW": "RawCapability"
};

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

  static Future<dynamic> initMic() async {
    return (await _channel.invokeMethod('initMic'));
  }

  static Future<dynamic> decode(int milliseconds) async {
    return (await _channel
        .invokeMethod('decode', {"milliseconds": milliseconds}));
  }

  static Future<List<dynamic>> getLogs() async {
    if (!kIsWeb) {
      String reply = await _channel.invokeMethod('getLogs');
      List<dynamic> splittedReply = jsonDecode(reply);
      print("Logs output: $splittedReply");
      return splittedReply;
    } else {
      List<dynamic> reply = await _channel.invokeMethod('getLogs');
      return reply;
    }
  }

  static Future<dynamic> get manifest async {
    dynamic reply = await _channel.invokeMethod('getManifest');
    print("Manifest output: $reply");
    if (!kIsWeb) {
      List<dynamic> capabilities = jsonDecode(reply);
      //[{kind: SOUND, id: 1, args: {sample_duration_ms: 1000, source: 0, hz: 16000}}] to
      // [{"type":"ImageCapability","width":96,"pixel_format":2,"height":96}]

      List manifest = [];
      for (dynamic element in capabilities) {
        Map<String, dynamic> cap = {
          "type": capabilitiesDefinitionString[element["kind"]]
        };
        for (dynamic param in element["args"].keys) {
          cap[param] = int.tryParse("${element["args"][param]}");
        }
        manifest.add(cap);
      }
      return manifest;
    }

    return jsonDecode("$reply");
  }

  static Future<dynamic> runRune() async {
    final dynamic result = await _channel.invokeMethod('runRune');
    return result;
  }

  static Future<dynamic> addInputTensor(
      int nodeId, Uint8List input, int type, List<int> dimensions) async {
    final dynamic result = await _channel.invokeMethod('addInputTensor', {
      "nodeID": nodeId,
      "bytes": input,
      "type": type,
      "dimensions": dimensions
    });
    return result;
  }
}
