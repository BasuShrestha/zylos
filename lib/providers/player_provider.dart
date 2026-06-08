import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../audio/audio_handler.dart';
import '../data/models/player_state_model.dart';
import '../data/models/song_model.dart';

final audioHandlerProvider = Provider<ZylosAudioHandler>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

final playerProvider = NotifierProvider<PlayerNotifier, PlayerStateModel>(
  PlayerNotifier.new,
);

class PlayerNotifier extends Notifier<PlayerStateModel> {
  late final ZylosAudioHandler _handler;

  // PlayerNotifier(this._handler) : super(const PlayerStateModel()) {
  //   _listenToPlayer();
  // }

  @override
  PlayerStateModel build() {
    _handler = ref.watch(audioHandlerProvider);
    _listenToPlayer();
    return const PlayerStateModel();
  }

  void _listenToPlayer() {
    _handler.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _handler.durationStream.listen((duration) {
      state = state.copyWith(duration: duration ?? Duration.zero);
    });

    _handler.playingStream.listen((isPlaying) {
      state = state.copyWith(isPlaying: isPlaying);
    });

    _handler.currentIndexStream.listen((index) {
      if (index == null) return;
      if (index == state.currentIndex) return;
      if (index < 0 || index >= state.queue.length) return;

      state = state.copyWith(
        currentIndex: index,
        currentSong: state.queue[index],
        position: Duration.zero,
      );
    });

    _handler.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        next();
      }
    });
  }

  Future<void> playSong(List<SongModel> queue, int index) async {
    state = state.copyWith(
      currentSong: queue[index],
      queue: queue,
      currentIndex: index,
      position: Duration.zero,
    );
    await _handler.playQueue(queue, index);
  }

  Future<void> togglePlayPause() async {
    state.isPlaying ? await _handler.pause() : await _handler.play();
  }

  Future<void> next() async {
    if (!state.hasNext) return;
    await _handler.seekToNext();
  }

  Future<void> previous() async {
    if (state.position.inSeconds > 3) {
      await _handler.seek(Duration.zero);
      return;
    }
    if (!state.hasPrevious) return;
    await _handler.seekToPrevious();
  }

  Future<void> seekTo(Duration position) => _handler.seek(position);
}

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';

// import '../audio/audio_handler.dart';
// import '../data/models/player_state_model.dart';
// import '../data/models/song_model.dart';

// final audioHandlerProvider = Provider<ZylosAudioHandler>((ref) {
//   throw UnimplementedError('Must be overridden in main.dart');
// });

// final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerStateModel>(
//   (ref) => PlayerNotifier(ref.watch(audioHandlerProvider)),
// );

// class PlayerNotifier extends StateNotifier<PlayerStateModel> {
//   final ZylosAudioHandler _handler;

//   PlayerNotifier(this._handler) : super(const PlayerStateModel()) {
//     _listenToPlayer();
//   }

//   void _listenToPlayer() {
//     _handler.player.positionStream.listen((position) {
//       state = state.copyWith(position: position);
//     });

//     _handler.player.durationStream.listen((duration) {
//       state = state.copyWith(duration: duration ?? Duration.zero);
//     });

//     _handler.player.playingStream.listen((isPlaying) {
//       state = state.copyWith(isPlaying: isPlaying);
//     });
//   }

//   Future<void> playSong(List<SongModel> queue, int index) async {
//     final song = queue[index];
//     state = state.copyWith(
//       currentSong: song,
//       queue: queue,
//       currentIndex: index,
//       position: Duration.zero,
//     );
//     await _handler.playFromSong(song);
//   }

//   Future<void> togglePlayPause() async {
//     if (state.isPlaying) {
//       await _handler.pause();
//     } else {
//       await _handler.play();
//     }
//   }

//   Future<void> next() async {
//     if (!state.hasNext) return;
//     await playSong(state.queue, state.currentIndex + 1);
//   }

//   Future<void> previous() async {
//     if (state.position.inSeconds > 3) {
//       await _handler.seek(Duration.zero);
//       return;
//     }
//     if (!state.hasPrevious) return;
//     await playSong(state.queue, state.currentIndex - 1);
//   }

//   Future<void> seekTo(Duration position) => _handler.seek(position);
// }
