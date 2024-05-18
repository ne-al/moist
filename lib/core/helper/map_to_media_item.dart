import 'package:audio_service/audio_service.dart';

class MapToMediaItem {
  MediaItem mapToMediaItem(Map<dynamic, dynamic> map) {
    String url = map['url'].replaceAll('_96', '_320');

    return MediaItem(
      id: url,
      album: map['album'],
      title: map['title'],
      artist: map['artist'],
      duration: Duration(seconds: int.parse(map['duration'])),
      artUri: Uri.parse(map['image']),
      extras: {
        'id': map['id'],
      },
    );
  }
}
