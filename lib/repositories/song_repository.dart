import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zylos/data/database/db_service.dart';
import 'package:zylos/data/models/song_model.dart';

class SongRepository {
  static const _audioExtensions = {
    '.mp3',
    '.flac',
    '.aac',
    '.ogg',
    '.wav',
    '.m4a',
    '.opus',
    '.wma',
  };

  // ── Permission ───────────────────────────────
  Future<bool> requestPermission() async {
    final audio = await Permission.audio.request();
    if (audio.isGranted) return true;
    final manage = await Permission.manageExternalStorage.request();
    if (manage.isGranted) return true;
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }

  // ── Fetch songs ──────────────────────────────
  Future<List<SongModel>> getSongs() async {
    final db = DBService.instance;
    final cached = await db.query('songs', orderBy: 'title COLLATE NOCASE ASC');
    if (cached.isNotEmpty) {
      return cached.map(SongModel.fromMap).toList();
    }
    return _scanAndCache();
  }

  // ── Rescan ───────────────────────────────────
  Future<List<SongModel>> rescan() async {
    await DBService.clearSongs();
    await _clearArtworkCache();
    return _scanAndCache();
  }

  // ── Internal: scan + save ────────────────────
  Future<List<SongModel>> _scanAndCache() async {
    final audioFiles = await _scanAudioFiles();
    if (audioFiles.isEmpty) return [];

    final artworkDir = await _artworkDirectory();
    final db = DBService.instance;
    final batch = db.batch();

    for (final file in audioFiles) {
      try {
        final metadata = readMetadata(file, getImage: true);

        // ── Save artwork to cache directory ──────
        String artworkPath = '';
        try {
          final picture = metadata.pictures[0]; //WORKAROUND FOR PICTURE
          if (picture.bytes.isNotEmpty) {
            // Use a hash of the file path as filename
            // so the same album shares one artwork file
            final artworkFile = File(
              '${artworkDir.path}/${file.path.hashCode.abs()}.jpg',
            );
            if (!artworkFile.existsSync()) {
              await artworkFile.writeAsBytes(picture.bytes);
            }
            artworkPath = artworkFile.path;
          }
        } catch (_) {}

        batch.insert('songs', {
          'title': metadata.title?.isNotEmpty == true
              ? metadata.title!
              : SongModel.titleFromPath(file.path),
          'artist': metadata.artist?.isNotEmpty == true
              ? metadata.artist!
              : 'Unknown Artist',
          'album': metadata.album?.isNotEmpty == true
              ? metadata.album!
              : 'Unknown Album',
          'genre': metadata.genres.isNotEmpty == true
              ? metadata.genres.first
              : 'Unknown Genre',
          'track_number': metadata.trackNumber ?? 0,
          'duration': metadata.duration?.inMilliseconds ?? 0,
          'path': file.path,
          'file_size': file.lengthSync(),
          'date_added': file.lastModifiedSync().millisecondsSinceEpoch,
          'artwork_path': artworkPath,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      } catch (_) {
        continue;
      }
    }

    await batch.commit(noResult: true);

    final saved = await db.query('songs', orderBy: 'title COLLATE NOCASE ASC');
    return saved.map(SongModel.fromMap).toList();
  }

  Future<List<File>> _scanAudioFiles() async {
    final results = <File>[];
    const skipPaths = {
      '/storage/emulated/0/Android/data',
      '/storage/emulated/0/Android/obb',
    };
    final scanTargets = [
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Recordings',
      '/storage/emulated/0/Audiobooks',
      '/storage/emulated/0/Documents',
      '/storage/emulated/0/DCIM',
      '/storage/emulated/0/Podcasts',
    ];

    for (final targetPath in scanTargets) {
      final dir = Directory(targetPath);
      if (!dir.existsSync()) continue;
      try {
        await for (final entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is! File) continue;
          if (skipPaths.any((s) => entity.path.startsWith(s))) continue;
          final dotIndex = entity.path.lastIndexOf('.');
          if (dotIndex == -1) continue;
          final ext = entity.path.substring(dotIndex).toLowerCase();
          if (_audioExtensions.contains(ext)) results.add(entity);
        }
      } catch (_) {
        continue;
      }
    }
    return results;
  }

  Future<Directory> _artworkDirectory() async {
    final cacheDir = await getApplicationCacheDirectory();
    final artworkDir = Directory('${cacheDir.path}/artwork');
    if (!artworkDir.existsSync()) {
      await artworkDir.create(recursive: true);
    }
    return artworkDir;
  }

  Future<void> _clearArtworkCache() async {
    try {
      final dir = await _artworkDirectory();
      if (dir.existsSync()) await dir.delete(recursive: true);
    } catch (_) {}
  }
}
