import 'package:logger/logger.dart';
import 'package:moist/core/api/saavn/api.dart';

class MediaManager {
  Future<void> playRadio(item) async {
    String? stationId = await SaavnAPI().createRadio(
      names: item['more_info']['featured_station_type'].toString() == 'artist'
          ? [item['more_info']['query'].toString()]
          : [item['id'].toString()],
      language: item['more_info']['language']?.toString() ?? 'hindi',
      stationType: item['more_info']['featured_station_type'].toString(),
    );

    if (stationId == null) return;
    List songs = await SaavnAPI().getRadioSongs(stationId: stationId);

    //TODO add play back logic here
    Logger().d(songs);
  }
}
