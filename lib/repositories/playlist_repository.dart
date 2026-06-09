import 'package:sqflite/sqflite.dart';
import 'package:zylos/data/database/db_service.dart';
import 'package:zylos/data/models/playlist_model.dart';
import 'package:zylos/data/models/song_model.dart';

class PlaylistRepository {
  Database get _db => DBService.instance;

  Future<List<PlaylistModel>> getPlaylists() async {
    final rows = await _db.rawQuery('''
      SELECT
        p.id,
        p.name,
        p.created_at,
        p.updated_at,
        COUNT(ps.song_id) as song_count,
        COALESCE(
          (SELECT s.artwork_path
           FROM playlist_songs ps2
           JOIN songs s ON s.id = ps2.song_id
           WHERE ps2.playlist_id = p.id
           AND s.artwork_path != ""
           ORDER BY ps2.position ASC
           LIMIT 1),
          ""
        ) as artwork_path
      FROM playlists p
      LEFT JOIN playlist_songs ps ON ps.playlist_id = p.id
      GROUP BY p.id
      ORDER BY p.updated_at DESC
    ''');
    return rows.map(PlaylistModel.fromMap).toList();
  }

  Future<List<SongModel>> getSongsForPlaylist(int playlistId) async {
    final psRows = await _db.query(
      'playlist_songs',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );
    print(
      'DEBUG: playlist_songs rows for playlist $playlistId = ${psRows.length}',
    );
    print('DEBUG: rows = $psRows');

    final rows = await _db.rawQuery(
      '''
      SELECT s.*
      FROM songs s
      JOIN playlist_songs ps ON ps.song_id = s.id
      WHERE ps.playlist_id = ?
      ORDER BY ps.position ASC
    ''',
      [playlistId],
    );
    print('DEBUG: songs found = ${rows.length}');
    return rows.map(SongModel.fromMap).toList();
  }

  Future<PlaylistModel> createPlaylist(String name) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = await _db.insert('playlists', {
      'name': name,
      'created_at': now,
      'updated_at': now,
    });

    return PlaylistModel(
      id: id,
      name: name,
      songCount: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> renamePlaylist(int id, String newName) async {
    await _db.update(
      'playlists',
      {'name': newName, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletePlaylist(int id) async {
    await _db.delete('playlists', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    print('DEBUG: adding song $songId to playlist $playlistId');
    final result = await _db.rawQuery(
      'SELECT COALESCE(MAX(position), -1) + 1 as next_pos FROM playlist_songs WHERE playlist_id = ?',
      [playlistId],
    );

    final nextPos = result.first['next_pos'] as int;
    print('DEBUG: next position = $nextPos');

    final insertResult = await _db.insert('playlist_songs', {
      'playlist_id': playlistId,
      'song_id': songId,
      'position': nextPos,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    print('DEBUG: insert result = $insertResult');

    await _db.update(
      'playlists',
      {'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    await _db.delete(
      'playlist_songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );
  }

  Future<bool> isSongInPlaylist(int playlistId, int songId) async {
    final result = await _db.query(
      'playlist_songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );
    return result.isNotEmpty;
  }
}
