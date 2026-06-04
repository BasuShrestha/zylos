import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static Database? _db;

  static Future<void> init() async {
    if (_db != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'zylos.db');

    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
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
        track_number INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('CREATE INDEX idx_title  ON songs(title  COLLATE NOCASE)');
    await db.execute('CREATE INDEX idx_artist ON songs(artist COLLATE NOCASE)');
    await db.execute('CREATE INDEX idx_album  ON songs(album  COLLATE NOCASE)');
  }

  static Database get instance {
    assert(_db != null, 'DBService.init() must be called before use');
    return _db!;
  }

  static Future<void> clearSongs() async {
    await instance.delete('songs');
  }
}
