import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/providers/player_provider.dart';

import 'artwork_widget.dart';

Future<void> showQueueSheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => const _QueueSheet(),
  );
}

class _QueueSheet extends ConsumerWidget {
  const _QueueSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(playerProvider.select((s) => s.queue));
    final currentIndex = ref.watch(
      playerProvider.select((s) => s.currentIndex),
    );
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Text(
                    'Queue',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${queue.length} songs',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: queue.isEmpty
                  ? const Center(child: Text('Queue is empty'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: queue.length,
                      itemBuilder: (ctx, index) {
                        final song = queue[index];
                        final isCurrent = index == currentIndex;

                        return ListTile(
                          tileColor: isCurrent
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          leading: Stack(
                            children: [
                              ArtworkWidget(
                                artworkPath: song.artworkPath,
                                size: 44,
                                borderRadius: BorderRadius.circular(6),
                                fallbackIcon: Icons.music_note,
                                fallbackIconSize: 20,
                              ),
                              if (isCurrent)
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
                          ),
                          title: Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: isCurrent
                                ? TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  )
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
                            ref
                                .read(playerProvider.notifier)
                                .playSong(queue, index);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
