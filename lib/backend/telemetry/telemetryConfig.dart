class TelemetryConfig {
  String? runeId;
  String? deviceGroupId;
  String? baseURL;
  int? interval;
  TelemetryConfig(
      {this.runeId, this.deviceGroupId, this.baseURL, this.interval});

  static TelemetryConfig defaultConfig = new TelemetryConfig(
      baseURL: "http://localhost:11000", interval: 10 * 1000);
}

class MetaData {
  String? apiKey;
  String? deploymentId;
  String? deviceId;
}
