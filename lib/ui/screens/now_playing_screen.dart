import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/ui/widgets/artwork_widget.dart';
import 'package:zylos/ui/widgets/seek_bar.dart';

import '../../../providers/player_provider.dart';
import '../../data/models/player_state_model.dart';

class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(playerProvider.select((s) => s.currentSong));
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));
    final hasNext = ref.watch(playerProvider.select((s) => s.hasNext));
    final hasPrevious = ref.watch(playerProvider.select((s) => s.hasPrevious));
    final isShuffled = ref.watch(playerProvider.select((s) => s.isShuffled));
    final repeatMode = ref.watch(playerProvider.select((s) => s.repeatMode));

    final colorScheme = Theme.of(context).colorScheme;

    if (song == null) {
      return const Scaffold(body: Center(child: Text('Nothing playing')));
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Now Playing',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Artwork ──────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Hero(
                    tag: 'artwork_${song.path}',
                    child: ArtworkWidget(
                      artworkPath: song.artworkPath,
                      size: double.infinity,
                      borderRadius: BorderRadius.circular(20),
                      fallbackIcon: Icons.music_note,
                      fallbackIconSize: 80,
                    ),
                  ),
                ),
              ),
            ),

            // ── Song info ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.artist,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Seek bar ─────────────────────────────
            const SeekBar(),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  IconButton(
                    onPressed: () =>
                        ref.read(playerProvider.notifier).toggleShuffle(),
                    icon: Icon(
                      Icons.shuffle_rounded,
                      color: isShuffled
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),

                  IconButton(
                    onPressed: () =>
                        ref.read(playerProvider.notifier).toggleRepeat(),
                    icon: Icon(
                      repeatMode == RepeatMode.one
                          ? Icons.repeat_one_rounded
                          : Icons.repeat_rounded,
                      color: repeatMode != RepeatMode.none
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Controls ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 40,
                    onPressed: hasPrevious
                        ? () => ref.read(playerProvider.notifier).previous()
                        : null,
                    icon: Icon(
                      Icons.skip_previous_rounded,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      iconSize: 40,
                      color: colorScheme.onPrimary,
                      onPressed: () =>
                          ref.read(playerProvider.notifier).togglePlayPause(),
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: 40,
                    onPressed: hasNext
                        ? () => ref.read(playerProvider.notifier).next()
                        : null,
                    icon: Icon(
                      Icons.skip_next_rounded,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
