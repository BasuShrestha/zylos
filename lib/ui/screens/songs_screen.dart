import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/providers/song_provider.dart';

class SongsScreen extends ConsumerWidget {
  const SongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Songs')),
      body: songsAsync.when(
        data: (songs) {
          if (songs.isEmpty) {
            return const Center(child: Text('No songs found on the device.'));
          }
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                title: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                onTap: () {},
              );
            },
          );
        },
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: .min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text('Failed to load songs\n$e', textAlign: .center),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
