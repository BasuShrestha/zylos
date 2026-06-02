import 'package:isar/isar.dart';

part 'song_collection.g.dart';

@Collection()
class SongCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: false)
  late int deviceId;

  @Index(caseSensitive: false)
  late String title;

  @Index(caseSensitive: false)
  late String artist;

  @Index(caseSensitive: false)
  late String album;

  @Index(caseSensitive: false)
  late String genre;

  late int duration;

  late String path;

  late int dateAdded;

  late int trackNumber;
}
