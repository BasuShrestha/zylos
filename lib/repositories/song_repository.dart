import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/database/db_service.dart';
import '../data/models/song_model.dart';

import 'package:sqflite/sqflite.dart';

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

  Future<bool> requestPermission() async {
    // Android 13+
    final audio = await Permission.audio.request();
    print('DEBUG: audio permission = ${audio.isGranted}');

    // Android 11+ — needed for full file system scan
    final manage = await Permission.manageExternalStorage.request();
    print('DEBUG: manage storage permission = ${manage.isGranted}');

    if (audio.isGranted || manage.isGranted) return true;

    // Fallback for Android 10 and below
    final storage = await Permission.storage.request();
    print('DEBUG: storage permission = ${storage.isGranted}');
    return storage.isGranted;
  }

  Future<List<SongModel>> getSongs() async {
    final db = DBService.instance;

    final cached = await db.query('songs', orderBy: 'title COLLATE NOCASE ASC');

    print('DEBUG: cached songs count = ${cached.length}');

    if (cached.isNotEmpty) {
      return cached.map(SongModel.fromMap).toList();
    }

    return _scanAndCache();
  }

  Future<List<SongModel>> rescan() async {
    await DBService.clearSongs();
    return _scanAndCache();
  }

  Future<List<SongModel>> _scanAndCache() async {
    final audioFiles = await _scanAudioFiles();
    print('DEBUG: audio files to process = ${audioFiles.length}');
    if (audioFiles.isEmpty) return [];

    final db = DBService.instance;
    final batch = db.batch();

    for (final file in audioFiles) {
      try {
        final metadata = readMetadata(file, getImage: false);

        final map = {
          'title': metadata.title?.isNotEmpty == true
              ? metadata.title!
              : SongModel.titleFromPath(file.path),
          'artist': metadata.artist?.isNotEmpty == true
              ? metadata.artist!
              : 'Unknown Artist',
          'album': metadata.album?.isNotEmpty == true
              ? metadata.album!
              : 'Unknown Album',
          'genre': (metadata.genres.isNotEmpty == true)
              ? metadata.genres.first
              : 'Unknown Genre',
          'duration': metadata.duration?.inMilliseconds ?? 0,
          'path': file.path,
          'file_size': file.lengthSync(),
          'date_added': file.lastModifiedSync().millisecondsSinceEpoch,
          'track_number': metadata.trackNumber ?? 0,
        };

        batch.insert('songs', map, conflictAlgorithm: ConflictAlgorithm.ignore);
      } catch (_) {
        continue;
      }
    }

    await batch.commit(noResult: true);

    final saved = await db.query('songs', orderBy: 'title COLLATE NOCASE ASC');
    print('DEBUG: sample song: $saved');

    return saved.map(SongModel.fromMap).toList();
  }

  Future<List<File>> _scanAudioFiles() async {
    final results = <File>[];

    // Folders to skip — restricted on Android 10+
    const skipPaths = {
      '/storage/emulated/0/Android/data',
      '/storage/emulated/0/Android/obb',
    };

    // Scan these folders directly instead of full recursive scan
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

          // Skip if inside a restricted path
          if (skipPaths.any((skip) => entity.path.startsWith(skip))) continue;

          final path = entity.path;
          final dotIndex = path.lastIndexOf('.');
          if (dotIndex == -1) continue;

          final ext = path.substring(dotIndex).toLowerCase();
          if (_audioExtensions.contains(ext)) {
            results.add(entity);
            print('DEBUG: found = $path');
          }
        }
      } catch (e) {
        // Skip this folder and continue to the next
        print('DEBUG: skipping $targetPath — $e');
        continue;
      }
    }

    print('DEBUG: total files found = ${results.length}');
    return results;
  }
}
