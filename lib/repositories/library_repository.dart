import 'package:sqflite/sqlite_api.dart';
import 'package:zylos/data/database/db_service.dart';
import 'package:zylos/data/models/album_model.dart';
import 'package:zylos/data/models/artist_model.dart';
import 'package:zylos/data/models/genre_model.dart';
import 'package:zylos/data/models/song_model.dart';

class LibraryRepository {
  Database get _db => DBService.instance;

  //Albums
  Future<List<AlbumModel>> getAlbums() async {
    final rows = await _db.rawQuery('''
    SELECT 
      album, 
      artist, 
      COUNT(*) as song_count, 
      SUM(duration) as total_duration, 
      MAX(artwork_path) as artwork_path 
      FROM songs 
      GROUP BY album, artist 
      ORDER BY album COLLATE NOCASE ASC
  ''');
    return rows.map(AlbumModel.fromMap).toList();
  }

  //Songs in a specific album
  Future<List<SongModel>> getSongsForAlbum(String album) async {
    final rows = await _db.query(
      'songs',
      where: 'album = ?',
      whereArgs: [album],
      orderBy: 'track_number ASC, title COLLATE NOCASE ASC',
    );
    return rows.map(SongModel.fromMap).toList();
  }

  //Artists
  Future<List<ArtistModel>> getArtists() async {
    final rows = await _db.rawQuery('''
      SELECT 
        artist,
        Count(*) as song_count,
        COUNT(DISTINCT album) as album_count,
        -- Pick artwork from the most recently added song 
        -- COALESCE skips empty strings and picks first non-empty
        artwork_path as artwork_path  
        FROM songs s1
        WHERE date_added = (
          SELECT MAX(s2.date_added)
          FROM songs s2 
          WHERE s2.artist = s1.artist 
          AND s2.artwork_path != ""
        )
        GROUP BY artist 
        ORDER BY artist COLLATE NOCASE ASC
    ''');
    if (rows.isEmpty) {
      final fallback = await _db.rawQuery('''
      SELECT 
        artist,
        COUNT(*) as song_count,
        COUNT(DISTINCT album) as album_count,
        MAX(artwork_path) as artwork_path
        FROM songs 
        GROUP BY artist 
        ORDER BY artist COLLATE NOCASE ASC
      ''');
      return fallback.map(ArtistModel.fromMap).toList();
    }

    return rows.map(ArtistModel.fromMap).toList();
  }

  //Songs of a specific artist
  Future<List<SongModel>> getSongsForArtist(String artist) async {
    final rows = await _db.query(
      'songs',
      where: 'artist = ?',
      whereArgs: [artist],
      orderBy: 'album COLLATE NOCASE ASC, track_number ASC',
    );
    return rows.map(SongModel.fromMap).toList();
  }

  //Genres
  Future<List<GenreModel>> getGenres() async {
    final rows = await _db.rawQuery('''
      SELECT
        genre,
        Count(*) as song_count 
        FROM songs 
        GROUP BY genre 
        ORDER BY genre COLLATE NOCASE ASC
    ''');
    return rows.map(GenreModel.fromMap).toList();
  }

  //Songs of a specific genre
  Future<List<SongModel>> getSongsForGenre(String genre) async {
    final rows = await _db.query(
      'songs',
      where: 'genre = ?',
      whereArgs: [genre],
      orderBy: 'title COLLATE NOCASE ASC',
    );
    return rows.map(SongModel.fromMap).toList();
  }
}
