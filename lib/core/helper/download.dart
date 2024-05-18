import 'dart:io';

Future<String> getSongUrl(
  String id,
) async {
  String quality = 'Medium';

  id = id.replaceFirst('youtube', '');
  return 'http://${InternetAddress.loopbackIPv4.host}:8080?id=$id&q=$quality';
}
