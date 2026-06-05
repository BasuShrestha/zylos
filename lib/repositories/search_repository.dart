import 'package:zylos/data/database/db_service.dart';
import 'package:zylos/data/models/album_model.dart';
import 'package:zylos/data/models/artist_model.dart';
import 'package:zylos/data/models/genre_model.dart';
import 'package:zylos/data/models/search_results.dart';
import 'package:zylos/data/models/song_model.dart';

class SearchRepository {
  Future<SearchResults> search(String query) async {
    if (query.trim().isEmpty) {
      return const SearchResults(
        songs: [],
        albums: [],
        artists: [],
        genres: [],
      );
    }

    final db = DBService.instance;
    final term = '%${query.trim()}%';

    final results = await Future.wait([
      db.rawQuery(
        '''
        SELECT * FROM songs 
        WHERE title LIKE ? OR artist LIKE ? 
        ORDER BY title COLLATE NOCASE ASC 
        LIMIT 10      
      ''',
        [term, term],
      ),
      db.rawQuery(
        '''
        SELECT album, artist, 
        COUNT(*) as song_count, 
        SUM(duration) as total_duration 
        FROM songs 
        WHERE album LIKE ? 
        GROUP BY album, artist 
        ORDER BY album COLLATE NOCASE ASC 
        LIMIT 6
      ''',
        [term],
      ),
      db.rawQuery(
        '''
        SELECT artist, COUNT(*) as song_count,
        COUNT(DISTINCT album) as album_count 
        FROM songs 
        WHERE artist LIKE ? 
        GROUP BY artist 
        ORDER BY artist COLLATE NOCASE ASC 
        LIMIT 6
      ''',
        [term],
      ),
      db.rawQuery(
        '''
        SELECT genre, COUNT(*) as song_count 
        FROM songs 
        WHERE genre LIKE ? 
        GROUP BY genre 
        ORDER BY genre COLLATE NOCASE ASC 
        LIMIT 6
      ''',
        [term],
      ),
    ]);

    return SearchResults(
      songs: results[0].map(SongModel.fromMap).toList(),
      albums: results[1].map(AlbumModel.fromMap).toList(),
      artists: results[2].map(ArtistModel.fromMap).toList(),
      genres: results[3].map(GenreModel.fromMap).toList(),
    );
  }
}
