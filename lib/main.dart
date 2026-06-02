import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:zylos/app.dart';
import 'package:zylos/data/database/isar_service.dart';

late Isar isar;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await IsarService.init();

  runApp(const ProviderScope(child: Zylos()));
}
