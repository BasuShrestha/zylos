import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zylos/data/models/song_model.dart';

import 'player_provider.dart';

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

final colorSchemeNotifierProvider =
    NotifierProvider<ColorSchemeNotifier, ColorScheme>(ColorSchemeNotifier.new);

class ColorSchemeNotifier extends Notifier<ColorScheme> {
  static final _defaultScheme = ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  );

  @override
  ColorScheme build() {
    ref.listen(
      playerProvider.select((s) => s.currentSong),
      (_, song) => _onSongChanged(song),
    );
    return _defaultScheme;
  }

  Future<void> _onSongChanged(SongModel? song) async {
    if (song == null || !song.hasArtwork) {
      state = _defaultScheme;
      return;
    }

    await Future.delayed(const Duration(seconds: 2));

    final currentSong = ref.read(playerProvider).currentSong;
    if (currentSong?.path != song.path) return;

    try {
      final palette = await PaletteGenerator.fromImageProvider(
        FileImage(File(song.artworkPath)),
        size: const Size(100, 100),
      );
      final dominantColor =
          palette.dominantColor?.color ??
          palette.vibrantColor?.color ??
          Colors.deepPurple;

      state = ColorScheme.fromSeed(
        seedColor: dominantColor,
        brightness: Brightness.dark,
      );
    } catch (_) {}
  }
}
