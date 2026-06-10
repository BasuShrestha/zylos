import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/data/models/song_model.dart';
import 'package:zylos/providers/playlist_provider.dart';
import 'package:zylos/ui/widgets/artwork_widget.dart';

Future<void> showAddToPlaylistSheet(
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
        mainAxisSize: .min,
        children: [
          Padding(
            padding: const EdgeInsetsGeometry.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Add to Playlist',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.add)),
            title: const Text('New Playlist'),
            onTap: () async {
              Navigator.pop(ctx);
              await _createAndAdd(context, ref, song);
            },
          ),
          if (playlists.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No playlists yet - create one above'),
            )
          else
            ...playlists.map(
              (playlist) => ListTile(
                leading: ArtworkWidget(
                  artworkPath: playlist.artworkPath,
                  size: 44,
                  borderRadius: .circular(6),
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

Future<void> _createAndAdd(
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
