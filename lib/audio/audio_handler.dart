import 'package:just_audio/just_audio.dart';
import '../data/models/song_model.dart';

class ZylosAudioHandler {
  // Single AudioPlayer instance — never recreated
  final _player = AudioPlayer();

  // Expose streams for PlayerNotifier to listen to
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  Future<void> playFromSong(SongModel song) async {
    await _player.setFilePath(song.path);
    await _player.play();
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration position) => _player.seek(position);

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
