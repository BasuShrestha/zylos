class AlbumModel {
  final String name;
  final String artist;
  final int songCount;
  final int totalDuration;

  const AlbumModel({
    required this.name,
    required this.artist,
    required this.songCount,
    required this.totalDuration,
  });

  factory AlbumModel.fromMap(Map<String, dynamic> map) {
    return AlbumModel(
      name: map['album'] as String,
      artist: map['artist'] as String,
      songCount: map['song_count'] as int,
      totalDuration: map['total_duration'] as int,
    );
  }

  String get formattedSongCount =>
      '$songCount ${songCount == 1 ? 'song' : 'songs'}';
}
