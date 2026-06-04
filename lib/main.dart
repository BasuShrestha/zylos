import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/audio/audio_handler.dart';
import 'package:zylos/providers/player_provider.dart';

import 'app.dart';
import 'data/database/db_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DBService.init();
  // await DBService.clearSongs();

  // final audioHandler = await AudioService.init(
  //   builder: () => ZylosAudioHandler(),
  //   config: const AudioServiceConfig(
  //     androidNotificationChannelId: 'com.zylos.audio',
  //     androidNotificationChannelName: 'Zylos Music',
  //     androidNotificationOngoing: true,
  //     androidStopForegroundOnPause: true,
  //   ),
  // );

  final audioHandler = ZylosAudioHandler();

  runApp(
    ProviderScope(
      overrides: [audioHandlerProvider.overrideWithValue(audioHandler)],
      child: Zylos(),
    ),
  );
}
