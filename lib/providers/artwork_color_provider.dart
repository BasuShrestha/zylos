import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';

import 'player_provider.dart';

// ─────────────────────────────────────────────
// Extracts dominant color from current song's
// artwork and builds a ColorScheme from it.
// Returns null if no artwork — UI falls back
// to default theme.
// ─────────────────────────────────────────────
final artworkColorProvider = FutureProvider<ColorScheme?>((ref) async {
  final song = ref.watch(playerProvider.select((s) => s.currentSong));

  if (song == null || !song.hasArtwork) return null;

  try {
    final palette = await PaletteGenerator.fromImageProvider(
      FileImage(File(song.artworkPath)),
      size: const Size(100, 100),
    );

    final dominantColor =
        palette.dominantColor?.color ??
        palette.vibrantColor?.color ??
        Colors.deepPurple;

    return ColorScheme.fromSeed(
      seedColor: dominantColor,
      brightness: Brightness.dark,
    );
  } catch (_) {
    return null;
  }
});
