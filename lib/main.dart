import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/database/db_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DBService.init();
  // await DBService.clearSongs();
  runApp(const ProviderScope(child: Zylos()));
}
