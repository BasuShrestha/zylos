import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/data/models/song_model.dart';
import 'package:zylos/providers/artwork_color_provider.dart';
import 'package:zylos/providers/player_provider.dart';
import 'package:zylos/providers/playlist_provider.dart';
import 'package:zylos/ui/screens/now_playing_screen.dart';
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
                onLongPress: () => _showAddToPlaylistSheet(context, ref, song),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddToPlaylistSheet(
    BuildContext context,
    WidgetRef ref,
    SongModel song,
  ) async {
    final playlists = await ref.read(playlistRepositoryProvider).getPlaylists();

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Add to Playlist',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            // Create new playlist option
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.add)),
              title: const Text('New Playlist'),
              // onLongPress: () => _showAddToPlaylistSheet(context, ref, song),
              onTap: () async {
                Navigator.pop(ctx);
                await _createAndAddToPlaylist(context, ref, song);
              },
            ),
            if (playlists.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No playlists yet — create one above.'),
              )
            else
              ...playlists.map(
                (playlist) => ListTile(
                  leading: ArtworkWidget(
                    artworkPath: playlist.artworkPath,
                    size: 44,
                    borderRadius: BorderRadius.circular(6),
                    fallbackIcon: Icons.queue_music,
                    fallbackIconSize: 20,
                  ),
                  title: Text(playlist.name),
                  subtitle: Text(playlist.formattedSongCount),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref
                        .read(playlistRepositoryProvider)
                        .addSongToPlaylist(playlist.id, song.id);
                    ref.invalidate(playlistsProvider);
                    ref.invalidate(songsForPlaylistProvider(playlist.id));

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added to ${playlist.name}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _createAndAddToPlaylist(
    BuildContext context,
    WidgetRef ref,
    SongModel song,
  ) async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.pop(ctx, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name == null || name.trim().isEmpty) return;

    final playlist = await ref
        .read(playlistRepositoryProvider)
        .createPlaylist(name.trim());

    await ref
        .read(playlistRepositoryProvider)
        .addSongToPlaylist(playlist.id, song.id);

    ref.invalidate(playlistsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to ${playlist.name}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
