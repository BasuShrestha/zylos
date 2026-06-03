import 'package:flutter/material.dart';
import 'ui/screens/songs/songs_screen.dart';

class Zylos extends StatelessWidget {
  const Zylos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zylos',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true),
      theme: ThemeData.light(useMaterial3: true),
      home: const SongsScreen(),
    );
  }
}
