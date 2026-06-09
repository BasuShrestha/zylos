class ArtistModel {
  final String name;
  final int songCount;
  final int albumCount;
  final String artworkPath;

  ArtistModel({
    required this.name,
    required this.songCount,
    required this.albumCount,
    this.artworkPath = '',
  });

  factory ArtistModel.fromMap(Map<String, dynamic> map) {
    return ArtistModel(
      name: map['artist'] as String,
      songCount: map['song_count'] as int,
      albumCount: map['album_count'] as int,
      artworkPath: map['artwork_path'] as String? ?? '',
    );
  }

  String get subtitle =>
      '$albumCount ${albumCount == 1 ? 'album' : 'albums'} · '
      '$songCount ${songCount == 1 ? 'song' : 'songs'}';
}
