import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/providers/library_provider.dart';
import 'package:zylos/ui/screens/albums/album_detail_screen.dart';
import 'package:zylos/ui/widgets/artwork_widget.dart';

class AlbumsScreen extends ConsumerWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Albums')),
      body: albumsAsync.when(
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (albums) {
          if (albums.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: .min,
                children: [
                  Icon(Icons.album_outlined, size: 48),
                  SizedBox(height: 12),
                  Text('No albums found'),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AlbumDetailScreen(album: album),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Expanded(
                      child: ArtworkWidget(
                        artworkPath: album.artworkPath,
                        size: double.infinity,
                        borderRadius: BorderRadius.circular(12),
                        fallbackIcon: Icons.album,
                        fallbackIconSize: 48,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      album.name,
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontWeight: .w600),
                    ),
                    Text(
                      album.artist,
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      album.formattedSongCount,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
