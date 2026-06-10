import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/providers/artwork_color_provider.dart';
import 'package:zylos/providers/player_provider.dart';
import 'package:zylos/ui/screens/now_playing_screen.dart';
import 'package:zylos/ui/widgets/add_to_playlist_sheet.dart';
import 'package:zylos/ui/widgets/artwork_widget.dart';

import '../../../providers/song_provider.dart';

class SongsScreen extends ConsumerWidget {
  const SongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);

    final currentSong = ref.watch(playerProvider.select((s) => s.currentSong));
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));
    final colosScheme = ref.watch(colorSchemeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Songs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(songsProvider),
          ),
        ],
      ),

      body: songsAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Scanning your music...'),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              const Text('Could not load songs.'),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (songs) {
          if (songs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.music_off, size: 48),
                  SizedBox(height: 12),
                  Text('No songs found on device.'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 90),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final isCurrentSong = currentSong?.path == song.path;

              return ListTile(
                tileColor: isCurrentSong ? colosScheme.primaryContainer : null,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: isCurrentSong
                      ? Stack(
                          children: [
                            ArtworkWidget(
                              artworkPath: song.artworkPath,
                              size: 44,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        )
                      : ArtworkWidget(
                          artworkPath: song.artworkPath,
                          size: 44,
                          borderRadius: BorderRadius.circular(6),
                        ),
                ),
                title: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isCurrentSong
                      ? TextStyle(color: colosScheme.primary, fontWeight: .w600)
                      : null,
                ),
                subtitle: Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  song.formattedDuration,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  if (isCurrentSong) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NowPlayingScreen(),
                        fullscreenDialog: true,
                      ),
                    );
                    // ref.read(playerProvider.notifier).togglePlayPause();
                  } else {
                    ref.read(playerProvider.notifier).playSong(songs, index);
                  }
                },
                onLongPress: () => showAddToPlaylistSheet(context, ref, song),
              );
            },
          );
        },
      ),
    );
  }
}
