import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zylos/providers/artwork_color_provider.dart';
import 'package:zylos/ui/screens/home/home_screen.dart';

class Zylos extends ConsumerWidget {
  const Zylos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkScheme = ref.watch(colorSchemeNotifierProvider);

    final lightScheme = ColorScheme.fromSeed(
      seedColor: darkScheme.primary,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Zylos',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkScheme),
      theme: ThemeData(useMaterial3: true, colorScheme: lightScheme),
      home: const HomeScreen(),
    );
  }
}
