class Message {
  final String type;
  final String? payload;
  Message(this.type, [this.payload]);

  static Map<String, dynamic> fetchingRune() {
    return {"type": "forge/fetch/started"};
  }

  static Map<String, dynamic> fetchingRuneFailed(
      String? error, String? message, int? milliseconds) {
    return {
      "type": "forge/fetch/failed",
      "error": error,
      "message": message,
      "milliseconds": milliseconds.toString(),
    };
  }

  static Map<String, dynamic> fetchSuceeded(int bytes, int milliseconds) {
    return {
      "type": "forge/fetch/succeeded",
      "bytes": bytes.toString(),
      "milliseconds": milliseconds.toString(),
    };
  }

  static Map<String, dynamic> runeLoadStarted() {
    return {"type": "rune/load/started"};
  }

  static Map<String, dynamic> runeLoadComplete(int milliseconds) {
    return {
      "type": "rune/load/succeeded",
      "milliseconds": milliseconds.toString(),
    };
  }

  static Map<String, dynamic> runeLoadFailed(
      String? error, String? message, int? milliseconds) {
    return {
      "type": "rune/load/failed",
      "error": error,
      "message": message,
      "milliseconds": milliseconds.toString(),
    };
  }

  static Map<String, dynamic> predictStarted() {
    return {"type": "rune/predict/started"};
  }

  static Map<String, dynamic> predictComplete(int milliseconds) {
    return {
      "type": "rune/predict/succeeded",
      "milliseconds": milliseconds.toString(),
    };
  }

  static Map<String, dynamic> predictFailed(
      String? error, String? message, int? milliseconds) {
    return {
      "type": "rune/predict/failed",
      "error": error,
      "message": message,
      "milliseconds": milliseconds.toString(),
    };
  }
}
