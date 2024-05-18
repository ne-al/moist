import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moist/app/widgets/songtile/songtile.dart';
import 'package:moist/core/api/saavn/api.dart';
import 'package:moist/core/helper/map_to_media_item.dart';

class PlaylistView extends StatefulWidget {
  final String id;
  final String type;
  final String title;
  final String thumbnailUrl;
  final Map? list;
  const PlaylistView({
    super.key,
    required this.id,
    required this.type,
    required this.title,
    required this.thumbnailUrl,
    this.list,
  });

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  Map songMap = {};
  List<MediaItem> mediaItem = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    List list = [];
    if (widget.type == 'album') {
      songMap = await SaavnAPI().fetchAlbumSongs(widget.id);

      for (var item in songMap['songs']) {
        mediaItem.add(MapToMediaItem().mapToMediaItem(item));
      }
    } else if (widget.type == 'mix') {
      songMap = await SaavnAPI().getSongFromToken(
          widget.list!['perma_url'].toString().split('/').last, 'mix',
          n: 500 * 1, p: 1);

      for (var item in songMap['songs']) {
        mediaItem.add(MapToMediaItem().mapToMediaItem(item));
      }
    } else if (widget.type == 'playlist') {
      songMap = await SaavnAPI().fetchPlaylistSongs(widget.id);

      for (var item in songMap['songs']) {
        mediaItem.add(MapToMediaItem().mapToMediaItem(item));
      }
    } else if (widget.type == 'song') {
      songMap = await SaavnAPI().fetchSongDetails(widget.id);

      MediaItem song = MapToMediaItem().mapToMediaItem(songMap);

      mediaItem.add(song);
    } else if (widget.type == 'show') {
      Map songMap = await SaavnAPI().getSongFromToken(
          widget.list!['perma_url'].toString().split('/').last, 'show',
          n: 500 * 1, p: 1);
      list = songMap['songs'].map((e) {
        e['url'] = e['url']
            .toString()
            .substring(0, e['url'].toString().lastIndexOf('.') + 4);

        return e;
      }).toList();

      for (var item in list) {
        mediaItem.add(MapToMediaItem().mapToMediaItem(item));
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: constraints.maxHeight * 0.25,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Container(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(child: Container()),
                            SizedBox(
                              width: constraints.maxWidth * 0.35,
                              height: constraints.maxWidth * 0.35,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: widget.thumbnailUrl,
                                ),
                              ),
                            ),
                            const Gap(40),
                            Flexible(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.oswald(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Gap(6),
                                  Text(
                                    widget.type,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.oswald(
                                      fontSize: 18,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(35),
                          ],
                        ),
                        Flexible(child: Container()),
                      ],
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: mediaItem.length,
                  itemBuilder: (context, index) {
                    var song = mediaItem[index];
                    return SongTile(song: song);
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
