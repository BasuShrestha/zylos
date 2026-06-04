import 'dart:io';

class SongModel {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String genre;
  final int duration;
  final String path;
  final int fileSize;
  final int dateAdded;
  final int trackNumber;

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.genre,
    required this.duration,
    required this.path,
    required this.fileSize,
    required this.dateAdded,
    required this.trackNumber,
  });

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] as int,
      title: map['title'] as String,
      artist: map['artist'] as String,
      album: map['album'] as String,
      genre: map['genre'] as String,
      duration: map['duration'] as int,
      path: map['path'] as String,
      fileSize: map['file_size'] as int,
      dateAdded: map['date_added'] as int,
      trackNumber: map['track_number'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      'genre': genre,
      'duration': duration,
      'path': path,
      'file_size': fileSize,
      'date_added': dateAdded,
      'track_number': trackNumber,
    };
  }

  String get formattedDuration {
    final d = Duration(milliseconds: duration);
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static String titleFromPath(String path) {
    return File(path).uri.pathSegments.last.replaceAll(RegExp(r'\.\w+$'), '');
  }
}
