import 'package:zylos/data/database/collections/song_collection.dart';

class SongModel {
  final int id;
  final int deviceId;
  final String title;
  final String artist;
  final String album;
  final String genre;
  final int duration;
  final String path;
  final int dateAdded;
  final int trackNumber;

  const SongModel({
    required this.id,
    required this.deviceId,
    required this.title,
    required this.artist,
    required this.album,
    required this.genre,
    required this.duration,
    required this.path,
    required this.dateAdded,
    required this.trackNumber,
  });

  factory SongModel.fromCollection(SongCollection c) {
    return SongModel(
      id: c.id,
      deviceId: c.deviceId,
      title: c.title,
      artist: c.artist,
      album: c.album,
      genre: c.genre,
      duration: c.duration,
      path: c.path,
      dateAdded: c.dateAdded,
      trackNumber: c.trackNumber,
    );
  }

  String get formattedDuration {
    final ms = Duration(milliseconds: duration);
    final minutes = ms.inMinutes;
    final seconds = ms.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
