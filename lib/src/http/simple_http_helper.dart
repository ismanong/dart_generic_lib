import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

Future<String> simpleHttpHelperFileUpload(
    String url, Uint8List fileBytes, String filename) async {
  var request = http.MultipartRequest("POST", Uri.parse(url));
  request.files.add(http.MultipartFile.fromBytes(
    'filename',
    fileBytes,
    filename: filename, // 必填
    // contentType: MediaType('application', 'json'),
  ));
  var response = await request.send();
  String str = '';
  if (response.statusCode == 200) {
    print('Uploaded!');
    print('Response status: ${response.statusCode}');
    str = await response.stream.bytesToString();
  }
  return str;
}

Future<Uint8List> simpleHttpHelperGetFile(String url) async {
  var response = await http.get(Uri.parse(url));
  var fileBytes = response.bodyBytes;
  return fileBytes;
}
