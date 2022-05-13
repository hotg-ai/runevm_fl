import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum TensorType {
  U8,
  I8,
  U16,
  I16,
  U32,
  I32,
  F32,
  U64,
  I64,
  F64,
}

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

class Tensor {
  int id;
  Uint8List? bytes;
  List<int> dimensions;
  TensorType type;
  Tensor(dynamic data, this.dimensions, this.type, this.id) {
    this.bytes =
        Uint8List.view(data.buffer, data.offsetInBytes, data.lengthInBytes);
  }

  get data {
    if (bytes == null) {
      return null;
    }
    if (type == TensorType.U8) {
      return Uint8List.view(
          bytes!.buffer, bytes!.offsetInBytes, bytes!.lengthInBytes);
    } else if (type == TensorType.I8) {
      return Int8List.view(
          bytes!.buffer, bytes!.offsetInBytes, bytes!.lengthInBytes);
    } else if (type == TensorType.U16) {
      return Uint16List.view(
          bytes!.buffer, bytes!.offsetInBytes, bytes!.lengthInBytes);
    } else if (type == TensorType.I16) {
      return Uint16List.view(
          bytes!.buffer, bytes!.offsetInBytes, bytes!.lengthInBytes);
    } else if (type == TensorType.F32) {
      return Float32List.view(
          bytes!.buffer, bytes!.offsetInBytes, bytes!.lengthInBytes);
    } else if (type == TensorType.U32) {
      return Uint32List.view(
          bytes!.buffer, bytes!.offsetInBytes, bytes!.lengthInBytes);
    } else if (type == TensorType.I32) {
      return Int32List.view(
          bytes!.buffer, bytes!.offsetInBytes, bytes!.lengthInBytes);
    } else if (type == TensorType.F64) {
      return Float64List.view(
          bytes!.buffer, bytes!.offsetInBytes, bytes!.lengthInBytes);
    } else if (type == TensorType.U64) {
      return Uint64List.view(
          bytes!.buffer, bytes!.offsetInBytes, bytes!.lengthInBytes);
    } else if (type == TensorType.I64) {
      return Int64List.view(
          bytes!.buffer, bytes!.offsetInBytes, bytes!.lengthInBytes);
    }
    return null;
  }
}

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
          "type": capabilitiesDefinitionString[element["kind"]],
          "id": int.parse("${element["id"]}")
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

  static Future<dynamic> addInputTensor(Tensor input) async {
    final dynamic result = await _channel.invokeMethod('addInputTensor', {
      "nodeID": input.id,
      "bytes": input.bytes,
      "type": input.type.index,
      "dimensions": input.dimensions
    });
    return result;
  }
}
