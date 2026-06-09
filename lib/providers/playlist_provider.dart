import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/data/models/playlist_model.dart';
import 'package:zylos/data/models/song_model.dart';
import 'package:zylos/repositories/playlist_repository.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>(
  (ref) => PlaylistRepository(),
);

final playlistsProvider = FutureProvider<List<PlaylistModel>>((ref) {
  return ref.watch(playlistRepositoryProvider).getPlaylists();
});

final songsForPlaylistProvider = FutureProvider.family<List<SongModel>, int>((
  ref,
  playlistId,
) {
  return ref.watch(playlistRepositoryProvider).getSongsForPlaylist(playlistId);
});
