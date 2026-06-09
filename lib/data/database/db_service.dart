import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static Database? _db;

  static Future<void> init() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'zylos.db');

    _db = await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE songs (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT NOT NULL,
        artist      TEXT NOT NULL,
        album       TEXT NOT NULL,
        genre       TEXT NOT NULL,
        duration    INTEGER NOT NULL,
        path        TEXT NOT NULL UNIQUE,
        file_size   INTEGER NOT NULL,
        date_added  INTEGER NOT NULL,
        track_number INTEGER NOT NULL DEFAULT 0,
        artwork_path TEXT NOT NULL DEFAULT ""
      )
    ''');

    await db.execute('CREATE INDEX idx_title  ON songs(title  COLLATE NOCASE)');
    await db.execute('CREATE INDEX idx_artist ON songs(artist COLLATE NOCASE)');
    await db.execute('CREATE INDEX idx_album  ON songs(album  COLLATE NOCASE)');

    await _createPlaylistTables(db);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE songs ADD COLUMN artwork_path TEXT NOT NULL DEFAULT ""',
      );
    }
    if (oldVersion < 3) {
      await _createPlaylistTables(db);
    }
  }

  static Future<void> _createPlaylistTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute(''' 
      CREATE TABLE IF NOT EXISTS playlist_songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlist_id INTEGER NOT NULL,
        song_id INTEGER NOT NULL,
        position INTEGER NOT NULL,
        FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
        FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE,
        UNIQUE (playlist_id, song_id)
      )
    ''');
  }

  static Database get instance {
    assert(_db != null, 'DBService.init() must be called before use');
    return _db!;
  }

  static Future<void> clearSongs() async {
    await instance.delete('songs');
  }
}
