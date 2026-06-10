import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/ui/screens/now_playing_screen.dart';
import 'package:zylos/ui/widgets/add_to_playlist_sheet.dart';
import 'package:zylos/ui/widgets/artwork_widget.dart';

import '../../../data/models/artist_model.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/player_provider.dart';

class ArtistDetailScreen extends ConsumerWidget {
  final ArtistModel artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsForArtistProvider(artist.name));
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
        padding: const EdgeInsets.only(bottom: 90),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final song = songs[index];
            final isCurrentSong = currentSong?.path == song.path;

            return ListTile(
              onLongPress: () => showAddToPlaylistSheet(context, ref, song),
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
                    : Text(
                        song.title[0].toUpperCase(),
                        style: const TextStyle(fontSize: 14),
                      ),
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
                song.album,
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
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                artist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: ArtworkWidget(
                artworkPath: artist.artworkPath,
                size: double.infinity,
                borderRadius: .zero,
                fallbackIcon: Icons.percent,
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
                      artist.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
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

          songSliver,
        ],
      ),
    );
  }
}
