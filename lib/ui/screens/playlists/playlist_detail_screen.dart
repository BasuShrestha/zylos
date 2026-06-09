import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/data/models/playlist_model.dart';
import 'package:zylos/providers/player_provider.dart';
import 'package:zylos/providers/playlist_provider.dart';
import 'package:zylos/ui/screens/now_playing_screen.dart';
import 'package:zylos/ui/widgets/artwork_widget.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final PlaylistModel playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsForPlaylistProvider(playlist.id));
    final currentSong = ref.watch(playerProvider.select((s) => s.currentSong));
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));

    final Widget songSliver;
    if (songsAsync.isLoading) {
      songSliver = const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (songsAsync.hasError) {
      songSliver = SliverFillRemaining(
        child: Center(child: Text('Error: ${songsAsync.error}')),
      );
    } else {
      final songs = songsAsync.value ?? [];

      if (songs.isEmpty) {
        songSliver = const SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.music_off, size: 48),
                SizedBox(height: 12),
                Text(
                  'No songs in this playlist yet.\nLong press a song to add it.',
                ),
              ],
            ),
          ),
        );
      } else {
        songSliver = SliverPadding(
          padding: const EdgeInsets.only(bottom: 90),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final song = songs[index];
              final isCurrentSong = currentSong?.path == song.path;

              return ListTile(
                tileColor: isCurrentSong
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                leading: isCurrentSong
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
                        fallbackIcon: Icons.music_note,
                        fallbackIconSize: 20,
                      ),
                title: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isCurrentSong
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        )
                      : null,
                ),
                subtitle: Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      song.formattedDuration,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 20,
                      ),
                      onPressed: () async {
                        await ref
                            .read(playlistRepositoryProvider)
                            .removeSongFromPlaylist(playlist.id, song.id);
                        ref.invalidate(songsForPlaylistProvider(playlist.id));
                        ref.invalidate(playlistsProvider);
                      },
                    ),
                  ],
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
                  } else {
                    ref.read(playerProvider.notifier).playSong(songs, index);
                  }
                },
              );
            }, childCount: songs.length),
          ),
        );
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                playlist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: ArtworkWidget(
                artworkPath: playlist.artworkPath,
                size: double.infinity,
                borderRadius: BorderRadius.zero,
                fallbackIcon: Icons.queue_music,
                fallbackIconSize: 80,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      playlist.formattedSongCount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (songsAsync.value?.isNotEmpty == true)
                    FilledButton.icon(
                      onPressed: () => ref
                          .read(playerProvider.notifier)
                          .playSong(songsAsync.value!, 0),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Play All'),
                    ),
                ],
              ),
            ),
          ),
          songSliver,
        ],
      ),
    );
  }
}
