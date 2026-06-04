import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/library_provider.dart';
import 'genre_detail_screen.dart';

class GenresScreen extends ConsumerWidget {
  const GenresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genresAsync = ref.watch(genresProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Genres')),
      body: genresAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (genres) {
          if (genres.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.queue_music_outlined, size: 48),
                  SizedBox(height: 12),
                  Text('No genres found.'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: genres.length,
            padding: const EdgeInsets.only(bottom: 90),
            itemBuilder: (context, index) {
              final genre = genres[index];

              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.queue_music,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
                title: Text(
                  genre.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(genre.formattedSongCount),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GenreDetailScreen(genre: genre),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
