import 'package:http/http.dart' as http;

class ServerAPI{
  final http.Client httpClient;
  ServerAPI(this.httpClient);
  Future<http.Response> getRawCode(String url) async{
    final locationResponse;
    try {
      locationResponse = await this.httpClient.get(Uri.parse(url));
    }catch(e){
      throw Exception('bad response');
    }
    if (locationResponse.statusCode != 200) {
      throw Exception('bad response');
    }
    return locationResponse;
  }
}