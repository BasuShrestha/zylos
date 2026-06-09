import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:zylos/audio/audio_handler.dart';
import 'package:zylos/providers/player_provider.dart';

import 'app.dart';
import 'data/database/db_service.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await DBService.init();
  // await DBService.clearSongs();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.zylos.audio',
    androidNotificationChannelName: 'Zylos Music',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  final audioHandler = ZylosAudioHandler();

  FlutterNativeSplash.remove();

  runApp(
    ProviderScope(
      overrides: [audioHandlerProvider.overrideWithValue(audioHandler)],
      child: Zylos(),
    ),
  );
}
