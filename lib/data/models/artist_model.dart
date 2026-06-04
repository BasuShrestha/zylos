class ArtistModel {
  final String name;
  final int songCount;
  final int albumCount;

  ArtistModel({
    required this.name,
    required this.songCount,
    required this.albumCount,
  });

  factory ArtistModel.fromMap(Map<String, dynamic> map) {
    return ArtistModel(
      name: map['artist'] as String,
      songCount: map['song_count'] as int,
      albumCount: map['album_count'] as int,
    );
  }

  String get subtitle =>
      '$albumCount ${albumCount == 1 ? 'album' : 'albums'} · '
      '$songCount ${songCount == 1 ? 'song' : 'songs'}';
}
