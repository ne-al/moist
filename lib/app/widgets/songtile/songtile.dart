import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:moist/app/screen/music_player.dart';
import 'package:moist/main.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class SongTile extends StatelessWidget {
  final MediaItem song;
  const SongTile({
    super.key,
    required this.song,
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
          ),
          subtitle: Text(
            song.artist ?? 'Unknown',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_outline_rounded),
          ),
          onTap: () async {
            await audioHandler.updateQueue([song]);

            audioHandler.play();
            if (!context.mounted) return;
            pushScreenWithoutNavBar(
              context,
              const MusicPlayer(),
            );
          },
        );
      },
    );
  }
}
