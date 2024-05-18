import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moist/core/handler/audio_handler.dart';
import 'package:moist/core/handler/queue_state.dart';
import 'package:moist/core/helper/common.dart';
import 'package:moist/main.dart';
import 'package:rxdart/rxdart.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  Stream<Duration> get _bufferedPositionStream => audioHandler.playbackState
      .map((state) => state.bufferedPosition)
      .distinct();
  Stream<Duration?> get _durationStream =>
      audioHandler.mediaItem.map((item) => item?.duration).distinct();
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          AudioService.position,
          _bufferedPositionStream,
          _durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // MediaItem display
                StreamBuilder<MediaItem?>(
                  stream: audioHandler.mediaItem,
                  builder: (context, snapshot) {
                    final mediaItem = snapshot.data;
                    if (mediaItem == null) return const SizedBox();
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (mediaItem.artUri != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: mediaItem.artUri!.toString(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 54, vertical: 16),
                          child: Column(
                            children: [
                              Text(
                                mediaItem.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.oswald(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const Gap(6),
                              Text(
                                mediaItem.artist ?? 'Unknown',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.oswald(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // A seek bar.
                StreamBuilder<PositionData>(
                  stream: _positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data ??
                        PositionData(
                            Duration.zero, Duration.zero, Duration.zero);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ProgressBar(
                        total: positionData.duration,
                        progress: positionData.position,
                        buffered: positionData.bufferedPosition,
                        onSeek: (newPosition) {
                          audioHandler.seek(newPosition);
                        },
                        timeLabelLocation: TimeLabelLocation.sides,
                      ),
                    );
                  },
                ),
                // Playback controls
                ControlButtons(audioHandler),

                const SizedBox(height: 8.0),
                // Repeat/shuffle controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StreamBuilder<AudioServiceRepeatMode>(
                        stream: audioHandler.playbackState
                            .map((state) => state.repeatMode)
                            .distinct(),
                        builder: (context, snapshot) {
                          final repeatMode =
                              snapshot.data ?? AudioServiceRepeatMode.none;
                          const icons = [
                            Icon(Icons.repeat, color: Colors.grey),
                            Icon(Icons.repeat, color: Colors.orange),
                            Icon(Icons.repeat_one, color: Colors.orange),
                          ];
                          const cycleModes = [
                            AudioServiceRepeatMode.none,
                            AudioServiceRepeatMode.all,
                            AudioServiceRepeatMode.one,
                          ];
                          final index = cycleModes.indexOf(repeatMode);
                          return IconButton(
                            icon: icons[index],
                            onPressed: () {
                              audioHandler.setRepeatMode(cycleModes[
                                  (cycleModes.indexOf(repeatMode) + 1) %
                                      cycleModes.length]);
                            },
                          );
                        },
                      ),
                      StreamBuilder<bool>(
                        stream: audioHandler.playbackState
                            .map((state) =>
                                state.shuffleMode ==
                                AudioServiceShuffleMode.all)
                            .distinct(),
                        builder: (context, snapshot) {
                          final shuffleModeEnabled = snapshot.data ?? false;
                          return IconButton(
                            icon: shuffleModeEnabled
                                ? const Icon(Icons.shuffle,
                                    color: Colors.orange)
                                : const Icon(Icons.shuffle, color: Colors.grey),
                            onPressed: () async {
                              final enable = !shuffleModeEnabled;
                              await audioHandler.setShuffleMode(enable
                                  ? AudioServiceShuffleMode.all
                                  : AudioServiceShuffleMode.none);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Playlist
                // SizedBox(
                //   height: 240.0,
                //   child: StreamBuilder<QueueState>(
                //     stream: audioHandler.queueState,
                //     builder: (context, snapshot) {
                //       final queueState = snapshot.data ?? QueueState.empty;
                //       final queue = queueState.queue;
                //       return ReorderableListView(
                //         onReorder: (int oldIndex, int newIndex) {
                //           if (oldIndex < newIndex) newIndex--;
                //           audioHandler.moveQueueItem(oldIndex, newIndex);
                //         },
                //         children: [
                //           for (var i = 0; i < queue.length; i++)
                //             Dismissible(
                //               key: ValueKey(queue[i].id),
                //               background: Container(
                //                 color: Colors.redAccent,
                //                 alignment: Alignment.centerRight,
                //                 child: const Padding(
                //                   padding: EdgeInsets.only(right: 8.0),
                //                   child: Icon(Icons.delete, color: Colors.white),
                //                 ),
                //               ),
                //               onDismissed: (dismissDirection) {
                //                 audioHandler.removeQueueItemAt(i);
                //               },
                //               child: Material(
                //                 color: i == queueState.queueIndex
                //                     ? Colors.grey.shade300
                //                     : null,
                //                 child: ListTile(
                //                   title: Text(queue[i].title),
                //                   onTap: () => audioHandler.skipToQueueItem(i),
                //                 ),
                //               ),
                //             ),
                //         ],
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayerHandler audioHandler;

  const ControlButtons(this.audioHandler, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              value: audioHandler.volume.value,
              stream: audioHandler.volume,
              onChanged: audioHandler.setVolume,
            );
          },
        ),
        StreamBuilder<QueueState>(
          stream: audioHandler.queueState,
          builder: (context, snapshot) {
            final queueState = snapshot.data ?? QueueState.empty;
            return IconButton(
              iconSize: 50,
              icon: const Icon(Icons.skip_previous_rounded),
              onPressed:
                  queueState.hasPrevious ? audioHandler.skipToPrevious : null,
            );
          },
        ),
        StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, snapshot) {
            final playbackState = snapshot.data;
            final processingState = playbackState?.processingState;
            final playing = playbackState?.playing;
            if (processingState == AudioProcessingState.loading ||
                processingState == AudioProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 70,
                height: 70,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow_rounded),
                iconSize: 70,
                onPressed: audioHandler.play,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.pause_rounded),
                iconSize: 70,
                onPressed: audioHandler.pause,
              );
            }
          },
        ),
        StreamBuilder<QueueState>(
          stream: audioHandler.queueState,
          builder: (context, snapshot) {
            final queueState = snapshot.data ?? QueueState.empty;
            return IconButton(
              iconSize: 50,
              icon: const Icon(Icons.skip_next_rounded),
              onPressed: queueState.hasNext ? audioHandler.skipToNext : null,
            );
          },
        ),
        StreamBuilder<double>(
          stream: audioHandler.speed,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                value: audioHandler.speed.value,
                stream: audioHandler.speed,
                onChanged: audioHandler.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }
}
