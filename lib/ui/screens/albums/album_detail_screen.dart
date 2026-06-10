import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/data/models/album_model.dart';
import 'package:zylos/providers/library_provider.dart';
import 'package:zylos/providers/player_provider.dart';
import 'package:zylos/ui/screens/now_playing_screen.dart';
import 'package:zylos/ui/widgets/add_to_playlist_sheet.dart';
import 'package:zylos/ui/widgets/artwork_widget.dart';

class AlbumDetailScreen extends ConsumerWidget {
  final AlbumModel album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsForAlbumProvider(album.name));
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
      songSliver = SliverPadding(
        padding: const EdgeInsetsGeometry.only(bottom: 90),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final song = songs[index];
            final isCurrentSong = currentSong?.path == song.path;

            return ListTile(
              onLongPress: () => showAddToPlaylistSheet(context, ref, song),
              tileColor: isCurrentSong
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              leading: isCurrentSong
                  ? Stack(
                      children: [
                        ArtworkWidget(
                          artworkPath: song.artworkPath,
                          size: 44,
                          borderRadius: .circular(6),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: .circular(6),
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
                      borderRadius: .circular(6),
                      fallbackIcon: Icons.music_note,
                      fallbackIconSize: 20,
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
              subtitle: Text(song.artist, maxLines: 1, overflow: .ellipsis),
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
                  ref.read(playerProvider.notifier).playSong(songs, index);
                }
              },
            );
          }, childCount: songsAsync.value?.length ?? 0),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 270,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: ArtworkWidget(
                artworkPath: album.artworkPath,
                size: double.infinity,
                borderRadius: .zero,
                fallbackIcon: Icons.album,
                fallbackIconSize: 80,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsGeometry.fromLTRB(16, 12, 16, 4),
              child: Column(
                children: [
                  Text(
                    album.name,
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Row(
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
