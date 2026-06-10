import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/ui/screens/now_playing_screen.dart';
import 'package:zylos/ui/widgets/add_to_playlist_sheet.dart';

import '../../../data/models/genre_model.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/player_provider.dart';

class GenreDetailScreen extends ConsumerWidget {
  final GenreModel genre;

  const GenreDetailScreen({super.key, required this.genre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsForGenreProvider(genre.name));
    final currentSong = ref.watch(playerProvider.select((s) => s.currentSong));
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));

    return Scaffold(
      appBar: AppBar(
        title: Text(genre.name),
        actions: [
          if (songsAsync.value?.isNotEmpty == true)
            IconButton(
              icon: const Icon(Icons.play_arrow_rounded),
              onPressed: () => ref
                  .read(playerProvider.notifier)
                  .playSong(songsAsync.value!, 0),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (songsAsync.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (songsAsync.hasError) {
            return Center(child: Text('Error: ${songsAsync.error}'));
          }

          final songs = songsAsync.value ?? [];

          if (songs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.queue_music_outlined, size: 48),
                  SizedBox(height: 12),
                  Text('No songs in this genre.'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: songs.length,
            padding: const EdgeInsets.only(bottom: 90),
            itemBuilder: (context, index) {
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
                  '${song.artist} · ${song.album}',
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
            },
          );
        },
      ),
    );
  }
}
