class PlaylistModel {
  final int id;
  final String name;
  final int songCount;
  final int createdAt;
  final int updatedAt;
  final String artworkPath;

  const PlaylistModel({
    required this.id,
    required this.name,
    required this.songCount,
    required this.createdAt,
    required this.updatedAt,
    this.artworkPath = '',
  });

  factory PlaylistModel.fromMap(Map<String, dynamic> map) {
    return PlaylistModel(
      id: map['id'] as int,
      name: map['name'] as String,
      songCount: map['song_count'] as int? ?? 0,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      artworkPath: map['artwork_path'] as String? ?? '',
    );
  }

  String get formattedSongCount =>
      '$songCount ${songCount == 1 ? 'song' : 'songs'}';
}
