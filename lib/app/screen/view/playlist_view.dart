import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moist/app/widgets/songtile/songtile.dart';
import 'package:moist/core/api/saavn/api.dart';
import 'package:moist/core/helper/extension.dart';
import 'package:moist/core/helper/map_to_media_item.dart';

class PlaylistView extends StatefulWidget {
  final Map list;
  const PlaylistView({
    super.key,
    required this.list,
  });

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  Map songMap = {};
  String thumbnailUrl = "";
  String title = "";
  List<MediaItem> mediaItem = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    setState(() {
      isLoading = true;
    });

    List list = [];

    thumbnailUrl =
        widget.list['image'].toString().replaceAll('150x150', '500x500');
    title = widget.list['title'].toString().unescape();

    if (widget.list['type'] == 'album') {
      songMap = await SaavnAPI().fetchAlbumSongs(widget.list['id']);

      for (var item in songMap['songs']) {
        mediaItem.add(MapToMediaItem().mapToMediaItem(item));
      }
    } else if (widget.list['type'] == 'mix') {
      songMap = await SaavnAPI().getSongFromToken(
          widget.list['perma_url'].toString().split('/').last, 'mix',
          n: 500 * 1, p: 1);

      for (var item in songMap['songs']) {
        mediaItem.add(MapToMediaItem().mapToMediaItem(item));
      }
    } else if (widget.list['type'] == 'playlist') {
      songMap = await SaavnAPI().fetchPlaylistSongs(widget.list['id']);

      for (var item in songMap['songs']) {
        mediaItem.add(MapToMediaItem().mapToMediaItem(item));
      }
    } else if (widget.list['type'] == 'song') {
      songMap = await SaavnAPI().fetchSongDetails(widget.list['id']);

      MediaItem song = MapToMediaItem().mapToMediaItem(songMap);

      mediaItem.add(song);
    } else if (widget.list['type'] == 'show') {
      Map songMap = await SaavnAPI().getSongFromToken(
          widget.list['perma_url'].toString().split('/').last, 'show',
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

    setState(() {
      isLoading = false;
    });
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
                                  imageUrl: thumbnailUrl,
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
                                    title,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.oswald(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Gap(6),
                                  Text(
                                    widget.list['type'],
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
                !isLoading
                    ? mediaItem.isNotEmpty
                        ? SliverList.builder(
                            itemCount: mediaItem.length,
                            itemBuilder: (context, index) {
                              var song = mediaItem[index];
                              return SongTile(song: song);
                            },
                          )
                        : const SliverToBoxAdapter(
                            child: Center(
                              child: Text('NO SONGS FOUND'),
                            ),
                          )
                    : const SliverToBoxAdapter(
                        child: LinearProgressIndicator(),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
