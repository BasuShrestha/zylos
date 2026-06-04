class GenreModel {
  final String name;
  final int songCount;

  GenreModel({required this.name, required this.songCount});

  factory GenreModel.fromMap(Map<String, dynamic> map) {
    return GenreModel(
      name: map['genre'] as String,
      songCount: map['song_count'] as int,
    );
  }

  String get formattedSongCount =>
      '$songCount ${songCount == 1 ? 'song' : 'songs'}'; // not appropriate for zero 0 songs
}
