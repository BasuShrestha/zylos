import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/ui/widgets/artwork_widget.dart';

import '../../../providers/library_provider.dart';
import 'artist_detail_screen.dart';

class ArtistsScreen extends ConsumerWidget {
  const ArtistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistsAsync = ref.watch(artistsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Artists')),
      body: artistsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (artists) {
          if (artists.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline, size: 48),
                  SizedBox(height: 12),
                  Text('No artists found.'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: artists.length,
            padding: const EdgeInsets.only(bottom: 90),
            itemBuilder: (context, index) {
              final artist = artists[index];

              return ListTile(
                leading: ArtworkWidget(
                  artworkPath: artist.artworkPath,
                  size: 48,
                  borderRadius: .circular(24),
                  fallbackIcon: Icons.person,
                  fallbackIconSize: 24,
                ),
                title: Text(
                  artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(artist.subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArtistDetailScreen(artist: artist),
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
