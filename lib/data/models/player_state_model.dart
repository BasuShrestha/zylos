import 'song_model.dart';

enum RepeatMode { none, one, all }

class PlayerStateModel {
  final SongModel? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final List<SongModel> queue;
  final int currentIndex;
  final bool isShuffled;
  final RepeatMode repeatMode;

  const PlayerStateModel({
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.queue = const [],
    this.currentIndex = -1,
    this.isShuffled = false,
    this.repeatMode = RepeatMode.none,
  });

  PlayerStateModel copyWith({
    SongModel? currentSong,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    List<SongModel>? queue,
    int? currentIndex,
    bool? isShuffled,
    RepeatMode? repeatMode,
  }) {
    return PlayerStateModel(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isShuffled: isShuffled ?? this.isShuffled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }

  bool get hasSong => currentSong != null;

  bool get hasNext => currentIndex < queue.length - 1;

  bool get hasPrevious => currentIndex > 0;
}
