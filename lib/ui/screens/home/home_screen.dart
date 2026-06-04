import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:zylos/ui/screens/albums/albums_screen.dart';
import 'package:zylos/ui/screens/songs/songs_screen.dart';
import 'package:zylos/ui/widgets/mini_player.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _screens = [SongsScreen(), AlbumsScreen()];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: currentTab, children: _screens),
          const Positioned(left: 0, right: 0, bottom: 10, child: MiniPlayer()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: (value) {
          ref.read(currentTabProvider.notifier).state = value;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.music_note_outlined),
            selectedIcon: Icon(Icons.music_note),
            label: 'Songs',
          ),
          NavigationDestination(
            icon: Icon(Icons.album_outlined),
            selectedIcon: Icon(Icons.album),
            label: 'Albums',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Artists',
          ),
          NavigationDestination(
            icon: Icon(Icons.queue_music_outlined),
            selectedIcon: Icon(Icons.queue_music),
            label: 'Genres',
          ),
        ],
      ),
    );
  }
}
