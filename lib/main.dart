import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:zylos/audio/audio_handler.dart';
import 'package:zylos/providers/player_provider.dart';

import 'app.dart';
import 'data/database/db_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DBService.init();
  // await DBService.clearSongs();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.zylos.audio',
    androidNotificationChannelName: 'Zylos Music',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  final audioHandler = ZylosAudioHandler();

  runApp(
    ProviderScope(
      overrides: [audioHandlerProvider.overrideWithValue(audioHandler)],
      child: Zylos(),
    ),
  );
}
