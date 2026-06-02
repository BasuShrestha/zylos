import 'package:isar/isar.dart';
import 'package:on_audio_query/on_audio_query.dart' hide SongModel;
import 'package:permission_handler/permission_handler.dart';
import 'package:zylos/data/database/collections/song_collection.dart';
import 'package:zylos/data/database/isar_service.dart';
import 'package:zylos/data/models/song_model.dart';

class SongRepository {
  final OnAudioQuery _query;

  SongRepository(this._query);

  Future<bool> requestPermission() async {
    final audio = await Permission.audio.request();
    if (audio.isGranted) return true;
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }

  Future<List<SongModel>> getSongs() async {
    final isar = IsarService.instance;

    final cached = await isar.songCollections.where().findAll();
    if (cached.isNotEmpty) {
      return cached.map(SongModel.fromCollection).toList();
    }

    return _scanAndCache();
  }

  Future<List<SongModel>> rescan() async {
    final isar = IsarService.instance;
    await isar.writeTxn(() async {
      await isar.songCollections.clear();
    });

    return _scanAndCache();
  }

  Future<List<SongModel>> _scanAndCache() async {
    final deviceSongs = await _query.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    final collections = deviceSongs
        .map(
          (s) => SongCollection()
            ..deviceId = s.id
            ..title = s.title
            ..artist = s.artist ?? 'Unknown Artist'
            ..album = s.album ?? 'Unknown Album'
            ..genre = s.genre ?? 'Unknown Genre'
            ..trackNumber = s.track ?? 0
            ..duration = s.duration ?? 0
            ..path = s.data
            ..dateAdded = s.dateAdded ?? 0,
        )
        .toList();

    final isar = IsarService.instance;
    await isar.writeTxn(() async {
      await isar.songCollections.putAll(collections);
    });

    return collections.map(SongModel.fromCollection).toList();
  }
}
