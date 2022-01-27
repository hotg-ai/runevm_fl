import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class Backend {
  final String apiKey;
  final String baseURL;

  Function onProgress = (int bytesLoaded, int totalBytes) {};

  Backend(this.apiKey, this.baseURL);

  Future<Uint8List> downloadRune(int deploymentId) async {
    print("downloadRune");
    final client = http.Client();
    final response = await client.get(url("/forge/deployment"),
        headers: {"x-api-key": "$apiKey", "deploymentId": "$deploymentId"});
    client.close();
    return response.bodyBytes;
  }

  Uri url(String endPoint) {
    return Uri.parse("$baseURL$endPoint".trim());
  }
}
