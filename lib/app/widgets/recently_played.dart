import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:moist/app/theme/text_style.dart';
import 'package:moist/core/helper/download.dart';
import 'package:moist/core/helper/image_res_modifier.dart';
import 'package:moist/core/manager/media_manager.dart';

class RecentlyPlayed extends StatelessWidget {
  const RecentlyPlayed({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('songHistory').listenable(),
      builder: (context, value, child) {
        List songsItems = value.values.toList();
        songsItems.sort((a, b) => b['time_added'].compareTo(a['time_added']));
        Logger().d(songsItems);
        return songsItems.isEmpty
            ? const SizedBox()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Recently Played',
                        style: textStyle(context, bold: true).copyWith(
                            color: Theme.of(context).colorScheme.primary)),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 193,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: songsItems.length,
                      itemBuilder: (context, index) {
                        Map mapSong = songsItems[index];
                        return FutureBuilder(
                          future: processSong(mapSong),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              MediaItem song = snapshot.data!;
                              return GestureDetector(
                                onTap: () {
                                  MediaManager()
                                      .addAndPlay(song, context, mapSong);
                                },
                                // onLongPress: () {
                                //   showSongOptions(context, Map.from(mapSong));
                                // },
                                child: SizedBox(
                                  width: song.extras!['type'] == 'video'
                                      ? 250
                                      : 150,
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: song.extras!['offline'] ==
                                                    true &&
                                                !song.artUri
                                                    .toString()
                                                    .startsWith('http')
                                            ? Image.file(
                                                File.fromUri(song.artUri!),
                                                height: 150,
                                                fit: BoxFit.fitHeight,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return CachedNetworkImage(
                                                    imageUrl: getImageUrl(
                                                        song.artUri.toString()),
                                                    height: 150,
                                                    fit: BoxFit.fitHeight,
                                                  );
                                                },
                                              )
                                            : CachedNetworkImage(
                                                imageUrl: getImageUrl(
                                                    song.artUri.toString()),
                                                height: 150,
                                                fit: BoxFit.fitHeight,
                                                errorWidget:
                                                    (context, url, error) {
                                                  return Container(
                                                    height: 150,
                                                    decoration: BoxDecoration(
                                                      color: Colors
                                                          .grey.shade600
                                                          .withAlpha(50),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: const Icon(
                                                      Icons.music_note_rounded,
                                                      size: 70,
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),
                                      const SizedBox(height: 5),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Center(
                                          child: AutoSizeText(
                                            song.title,
                                            style: smallTextStyle(context,
                                                bold: true),
                                            overflow: TextOverflow.clip,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
      },
    );
  }
}
