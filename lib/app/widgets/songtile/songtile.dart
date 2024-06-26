import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moist/core/manager/media_manager.dart';

class SongTile extends StatelessWidget {
  final MediaItem song;
  final Map songMap;
  const SongTile({
    super.key,
    required this.song,
    required this.songMap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListTile(
          leading: SizedBox(
            width: constraints.maxWidth * 0.134,
            height: constraints.maxWidth * 0.134,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: song.artUri.toString(),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.oswald(),
          ),
          subtitle: Text(
            song.artist ?? 'Unknown',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.oswald(),
          ),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_outline_rounded),
          ),
          onTap: () async {
            MediaManager().addAndPlay(
              song,
              context,
              songMap,
            );
          },
        );
      },
    );
  }
}
