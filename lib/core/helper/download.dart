import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:moist/core/api/saavn/api.dart';
import 'package:moist/core/helper/map_to_media_item.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getSongUrl(
  String id,
) async {
  String quality = 'Medium';

  id = id.replaceFirst('youtube', '');
  return 'http://${InternetAddress.loopbackIPv4.host}:8080?id=$id&q=$quality';
}

Future<Uri> getImageUri(String id) async {
  final tempDir = Platform.isAndroid
      ? (await getApplicationDocumentsDirectory()).path
      : (await getDownloadsDirectory())!
          .path
          .replaceAll('Downloads', 'Music/.Thumbnails');
  final file = await File('$tempDir/$id.jpg').create(recursive: true);

  return file.uri;
}

Future<MediaItem> processSong(Map song) async {
  MediaItem mediaItem;

  var songData = await SaavnAPI().fetchSongDetails(song['id']);

  mediaItem = MapToMediaItem().mapToMediaItem(songData);

  return mediaItem;
}
