import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/data/models/album_model.dart';
import 'package:zylos/data/models/artist_model.dart';
import 'package:zylos/data/models/genre_model.dart';
import 'package:zylos/data/models/song_model.dart';
import 'package:zylos/repositories/library_repository.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => LibraryRepository(),
);

final albumsProvider = FutureProvider<List<AlbumModel>>((ref) {
  return ref.watch(libraryRepositoryProvider).getAlbums();
});

final songsForAlbumProvider = FutureProvider.family<List<SongModel>, String>((
  ref,
  album,
) {
  return ref.watch(libraryRepositoryProvider).getSongsForAlbum(album);
});

final artistsProvider = FutureProvider<List<ArtistModel>>((ref) {
  return ref.watch(libraryRepositoryProvider).getArtists();
});

final songsForArtistProvider = FutureProvider.family<List<SongModel>, String>((
  ref,
  artist,
) {
  return ref.watch(libraryRepositoryProvider).getSongsForArtist(artist);
});

final genresProvider = FutureProvider<List<GenreModel>>((ref) {
  return ref.watch(libraryRepositoryProvider).getGenres();
});

final songsForGenreProvider = FutureProvider.family<List<SongModel>, String>((
  ref,
  genre,
) {
  return ref.watch(libraryRepositoryProvider).getSongsForGenre(genre);
});
