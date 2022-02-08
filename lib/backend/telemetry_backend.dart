import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:runevm_fl/backend/telemetry/telemetryConfig.dart';

class TelemetryBackend {
  String? baseURL;
  String? apiKey;
  Identifiers? meta;
  List<Metric> metrics = [];
  Function requestSend = () {};

  TelemetryBackend({MetaData? metaData, TelemetryConfig? config}) {
    if (config != null && metaData != null) {
      baseURL = config.baseURL;
      apiKey = metaData.apiKey;
      meta = Identifiers(
          deploymentId: int.parse("${metaData.deploymentId}"),
          deviceId: metaData.deviceId,
          deviceGroupId: config.deviceGroupId,
          runeId: config.runeId);
      throttle(callback: this.send(), delay: config.interval);
    }
  }

  static TelemetryBackend noopTelemetryBackend() {
    return TelemetryBackend();
  }

  report({required Metric message}) async {
    this.metrics.add(message);
    if (!waiting) {
      waiting = true;
      await send();
      waiting = false;
    }
  }

  send() async {
    if (baseURL != null && apiKey != null && meta != null) {
      await uploadMetrics(baseURL!, apiKey!, meta!, metrics);
      metrics = [];
    }
  }

  bool waiting = false;

  throttle({Function? callback, int? delay}) async {
    if (delay != null && callback != null) {
      new Future.delayed(Duration(milliseconds: delay),
          throttle(callback: callback, delay: delay));
      if (!waiting) {
        waiting = true;
        await callback();
        waiting = false;
      }
    }
  }

  static uploadMetrics(String baseURL, String apiKey, Identifiers meta,
      List<Metric> metrics) async {
    String endpoint = "$baseURL/forge/telemetry";
    Packet packet =
        new Packet(meta, new DateTime.now().millisecondsSinceEpoch, metrics);
    final client = http.Client();
    final response = await client.post(Uri.parse("$endpoint".trim()),
        headers: {"APIKEY": "$apiKey", "Content-Type": "application/json"},
        body: jsonEncode(packet));
    client.close();
    assertSuccess(endpoint, response);
  }

  static assertSuccess(String endpoint, http.Response response) {
    if (response.statusCode != 200) {
      throw Exception(
          "Telemetry RequestFailed @ $endpoint Status: [${response.statusCode}] ${response.reasonPhrase}");
    }
  }
}

class Identifiers {
  final int? deploymentId;
  final String? deviceId;
  final String? runeId;
  final String? deviceGroupId;
  Identifiers(
      {this.deploymentId, this.deviceId, this.runeId, this.deviceGroupId});

  Map<String, dynamic> toJson() => {
        'deploymentId': deploymentId,
        'deviceId': deviceId,
        'runeId': runeId,
        'deviceGroupId': deviceGroupId
      };
}

class Metric {
  final String type;
  final int timeStamp;
  Map<String, String>? payload;

  Metric(this.type, this.timeStamp, [this.payload]) {
    if (payload == null) {
      payload = {};
    }
  }

  Map<String, dynamic> toJson() =>
      {'type': type, 'timeStamp': timeStamp, 'payload': payload};
}

class Packet extends Identifiers {
  List<Metric>? metrics;
  final int timeStamp;

  Packet(Identifiers id, this.timeStamp, [this.metrics])
      : super(
            deploymentId: id.deploymentId,
            deviceId: id.deviceId,
            runeId: id.runeId,
            deviceGroupId: id.deviceGroupId) {
    if (metrics == null) {
      metrics = [];
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'deploymentId': deploymentId,
        'deviceId': deviceId,
        'runeId': runeId,
        'deviceGroupId': deviceGroupId,
        'timeStamp': timeStamp,
        'metrics': metrics
      };
}
