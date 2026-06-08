import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../data/models/song_model.dart';
import '../data/models/player_state_model.dart';

class ZylosAudioHandler {
  final _player = AudioPlayer();

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  Future<void> playQueue(List<SongModel> songs, int startIndex) async {
    final sources = songs.map((song) {
      return AudioSource.file(
        song.path,
        tag: MediaItem(
          id: song.path,
          title: song.title,
          artist: song.artist,
          album: song.album,
          duration: Duration(milliseconds: song.duration),
          artUri: song.hasArtwork ? Uri.file(song.artworkPath) : null,
        ),
      );
    }).toList();

    await _player.setAudioSources(
      sources,
      initialIndex: startIndex,
      initialPosition: Duration.zero,
    );

    await _player.play();
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> seekToNext() => _player.seekToNext();
  Future<void> seekToPrevious() => _player.seekToPrevious();

  Future<void> seekToIndex(int index) async {
    await _player.seek(Duration.zero, index: index);
  }

  Future<void> setShuffle(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
    if (enabled) await _player.shuffle();
  }

  Future<void> setRepeatMode(RepeatMode mode) async {
    switch (mode) {
      case RepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case RepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.all:
        await _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

// import 'package:audio_service/audio_service.dart';
// import 'package:just_audio/just_audio.dart';

// import '../data/models/song_model.dart';

// class ZylosAudioHandler extends BaseAudioHandler with SeekHandler {
//   final _player = AudioPlayer();

//   ZylosAudioHandler() {
//     _player.playbackEventStream.listen(_broadcastState);

//     _player.processingStateStream.listen((state) {
//       if (state == ProcessingState.completed) {
//         skipToNext();
//       }
//     });
//   }

//   AudioPlayer get player => _player;

//   Future<void> playFromSong(SongModel song) async {
//     mediaItem.add(
//       MediaItem(
//         id: song.path,
//         title: song.title,
//         artist: song.artist,
//         album: song.album,
//         duration: Duration(milliseconds: song.duration),
//       ),
//     );

//     await _player.setFilePath(song.path);
//     await _player.play();
//   }

//   @override
//   Future<void> play() => _player.play();

//   @override
//   Future<void> pause() => _player.pause();

//   @override
//   Future<void> seek(Duration position) => _player.seek(position);

//   @override
//   Future<void> stop() async {
//     await _player.stop();
//     await super.stop();
//   }

//   void _broadcastState(PlaybackEvent event) {
//     playbackState.add(
//       playbackState.value.copyWith(
//         controls: [
//           MediaControl.skipToPrevious,
//           _player.playing ? MediaControl.pause : MediaControl.play,
//           MediaControl.skipToNext,
//         ],
//         systemActions: const {MediaAction.seek},
//         processingState: {
//           ProcessingState.idle: AudioProcessingState.idle,
//           ProcessingState.loading: AudioProcessingState.loading,
//           ProcessingState.buffering: AudioProcessingState.buffering,
//           ProcessingState.ready: AudioProcessingState.ready,
//           ProcessingState.completed: AudioProcessingState.completed,
//         }[_player.processingState]!,
//         playing: _player.playing,
//         updatePosition: _player.position,
//         bufferedPosition: _player.bufferedPosition,
//         speed: _player.speed,
//       ),
//     );
//   }
// }
