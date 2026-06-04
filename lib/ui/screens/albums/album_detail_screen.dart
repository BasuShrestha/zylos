import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/data/models/album_model.dart';
import 'package:zylos/providers/library_provider.dart';
import 'package:zylos/providers/player_provider.dart';
import 'package:zylos/ui/screens/now_playing_screen.dart';

class AlbumDetailScreen extends ConsumerWidget {
  final AlbumModel album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsForAlbumProvider(album.name));
    final currentSong = ref.watch(playerProvider.select((s) => s.currentSong));
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(album.name, maxLines: 1, overflow: .ellipsis),
              background: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.album,
                  size: 80,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsGeometry.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          album.artist,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          album.formattedSongCount,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  songsAsync.whenData((songs) {
                        return FilledButton.icon(
                          onPressed: songs.isEmpty
                              ? null
                              : () => ref
                                    .read(playerProvider.notifier)
                                    .playSong(songs, 0),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Play All'),
                        );
                      }).value ??
                      const SizedBox.shrink(),
                ],
              ),
            ),
          ),

          songsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) =>
                SliverFillRemaining(child: Center(child: Text('Error: $e'))),
            data: (songs) => SliverPadding(
              padding: const EdgeInsetsGeometry.only(bottom: 90),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = songs[index];
                  final isCurrentSong = currentSong?.path == song.path;

                  return ListTile(
                    tileColor: isCurrentSong
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    leading: CircleAvatar(
                      backgroundColor: isCurrentSong
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      child: isCurrentSong
                          ? Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 20,
                            )
                          : Text('${index + 1}'),
                    ),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: isCurrentSong
                          ? TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: .w600,
                            )
                          : null,
                    ),
                    subtitle: Text(
                      song.artist,
                      maxLines: 1,
                      overflow: .ellipsis,
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
                      } else {
                        ref
                            .read(playerProvider.notifier)
                            .playSong(songs, index);
                      }
                    },
                  );
                }, childCount: songs.length),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
