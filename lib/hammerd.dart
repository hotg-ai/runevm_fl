import 'package:http/http.dart' as http;

const String host = "https://hammerd.hotg.ai";

class Hammerd {
  // Create data
  void createData(String rune) async {
    var url = Uri.parse(
        "$host/data/hotg-ai/$rune?filename=canvas.png&labels[]=test&verions=est&labels[]=android");
    var response = await http.post(url, body: {});
  }

  // Get data for a rune
  void getData(String rune) async {
    var url = Uri.parse("$host/data/hotg-ai/$rune/");
    var response = await http.post(url, body: {});
  }

  // Get job result
  void getJobResult(String job) async {
    var url = Uri.parse("$host/job/$job");
    var response = await http.post(url, body: {});
  }

  // Get Rune
  void getRune(String rune) async {
    var url = Uri.parse("$host/rune/hotg-ai/$rune/In-est");
    var response = await http.post(url, body: {});
  }
}
