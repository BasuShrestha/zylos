import 'package:zylos/data/models/album_model.dart';
import 'package:zylos/data/models/artist_model.dart';
import 'package:zylos/data/models/genre_model.dart';
import 'package:zylos/data/models/song_model.dart';

class SearchResults {
  final List<SongModel> songs;
  final List<AlbumModel> albums;
  final List<ArtistModel> artists;
  final List<GenreModel> genres;

  const SearchResults({
    required this.songs,
    required this.albums,
    required this.artists,
    required this.genres,
  });
  bool get isEmpty =>
      songs.isEmpty && albums.isEmpty && artists.isEmpty && genres.isEmpty;
}
