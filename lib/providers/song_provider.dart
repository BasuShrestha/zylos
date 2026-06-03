import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/song_model.dart';
import '../repositories/song_repository.dart';

final songRepositoryProvider = Provider<SongRepository>(
  (ref) => SongRepository(),
);

final songsProvider = FutureProvider<List<SongModel>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);

  final hasPermission = await repo.requestPermission();
  if (!hasPermission) return [];

  return repo.getSongs();
});
