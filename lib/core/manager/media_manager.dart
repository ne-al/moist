import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:moist/app/screen/music_player.dart';
import 'package:moist/app/utils/history.dart';
import 'package:moist/core/api/saavn/api.dart';
import 'package:moist/core/helper/map_to_media_item.dart';
import 'package:moist/main.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class MediaManager {
  Future<void> playRadio(item, BuildContext context) async {
    String? stationId = await SaavnAPI().createRadio(
      names: item['more_info']['featured_station_type'].toString() == 'artist'
          ? [item['more_info']['query'].toString()]
          : [item['id'].toString()],
      language: item['more_info']['language']?.toString() ?? 'hindi',
      stationType: item['more_info']['featured_station_type'].toString(),
    );

    if (stationId == null) return;
    List songs = await SaavnAPI().getRadioSongs(stationId: stationId);

    List<MediaItem> mediaItems = [];

    for (var item in songs) {
      mediaItems.add(MapToMediaItem().mapToMediaItem(item));
    }
    if (!context.mounted) return;
    pushScreenWithoutNavBar(
      context,
      const MusicPlayer(),
    );

    await addSongHistory(songs[0]);

    await audioHandler.updateQueue(mediaItems);
    audioHandler.play();
  }

  Future<void> addAndPlay(
      MediaItem song, BuildContext context, Map songMap) async {
    pushScreenWithoutNavBar(
      context,
      const MusicPlayer(),
    );

    await addSongHistory(songMap);

    if (audioHandler.mediaItem.value != song) {
      await audioHandler.updateQueue([song]);
      audioHandler.play();
    }
  }
}
