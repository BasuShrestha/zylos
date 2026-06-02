import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart' hide SongModel;
import 'package:zylos/data/models/song_model.dart';
import 'package:zylos/data/repositories/song_repository.dart';

final audioQueryProvider = Provider<OnAudioQuery>((ref) => OnAudioQuery());

final songRepositoryProvider = Provider<SongRepository>(
  (ref) => SongRepository(ref.watch(audioQueryProvider)),
);

final songsProvider = FutureProvider<List<SongModel>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);

  final hasPermission = await repo.requestPermission();
  if (!hasPermission) return [];

  return repo.getSongs();
});
