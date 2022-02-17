import 'dart:typed_data';

import 'package:runevm_fl/backend/backend.dart';
import 'package:runevm_fl/runevm_fl.dart';
import 'backend/telemetry_backend.dart';

class Forge {
  static int? deploymentId;
  static String? apiKey;
  static String? baseURL;
  static String? telemetryURL;
  static dynamic manifest;
  static bool loaded = false;
  static TelemetryBackend telemetry = TelemetryBackend.noopTelemetryBackend();

  static Future<dynamic> forge(Map<String, dynamic> parameters) async {
    print("Loading forge $parameters");
    if (parameters.containsKey("deploymentId")) {
      deploymentId = int.tryParse(parameters["deploymentId"]);
    } else {
      throw Exception('[ForgeSDK] No deploymentId found in JSON');
    }
    if (parameters.containsKey("apiKey")) {
      apiKey = parameters["apiKey"];
    } else {
      throw Exception('[ForgeSDK] No apiKey found in JSON');
    }
    if (parameters.containsKey("baseURL")) {
      baseURL = parameters["baseURL"];
    } else {
      throw Exception('[ForgeSDK] No baseURL found in JSON');
    }
    if (parameters.containsKey("telemetry")) {
      if (parameters["telemetry"].containsKey("baseURL")) {
        telemetryURL = parameters["telemetry"]["baseURL"];
      } else {
        throw Exception('[ForgeSDK] No telemetryURL found in JSON');
      }
    }
    Backend backend = new Backend(apiKey!, baseURL!);
    print("downloading");
    Uint8List runeBytes = await backend.downloadRune(deploymentId!);
    await RunevmFl.load(runeBytes);
    manifest = await RunevmFl.manifest;
    loaded = true;
    return manifest;
  }

  static Future<dynamic>? predict(List<Uint8List> inputData) {
    if (inputData.length == 1) {
      return RunevmFl.runRune(inputData[0]);
    } else {
      List<int> inputs = [];
      List<int> lengths = [];
      for (Uint8List input in inputData) {
        inputs.addAll(input);
        lengths.add(input.length);
        return RunevmFl.runRune(new Uint8List.fromList(inputs), lengths);
      }
    }
    return null;
  }
}
