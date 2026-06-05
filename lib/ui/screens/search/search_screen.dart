import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:zylos/ui/screens/now_playing_screen.dart';

import '../../../data/models/album_model.dart';
import '../../../data/models/artist_model.dart';
import '../../../data/models/genre_model.dart';
import '../../../data/models/song_model.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/search_provider.dart';
import '../albums/album_detail_screen.dart';
import '../artists/artist_detail_screen.dart';
import '../genres/genre_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  // late final _searchQueryNotifier = ref.read(searchQueryProvider.notifier);
  late final StateController<String> _searchNotifier;

  DateTime _lastChanged = DateTime.now();

  @override
  void initState() {
    super.initState();
    _searchNotifier = ref.read(searchQueryProvider.notifier);
  }

  @override
  void dispose() {
    _controller.dispose();
    // Future.microtask(() {
    //   ref.read(searchQueryProvider.notifier).state = '';
    // });
    // _searchQueryNotifier.state = '';
    _searchNotifier.state = '';
    super.dispose();
  }

  void _onChanged(String value) {
    _lastChanged = DateTime.now();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (DateTime.now().difference(_lastChanged).inMilliseconds >= 300) {
        ref.read(searchQueryProvider.notifier).state = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Songs, albums, artists, genres...',
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _controller.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (query.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Search your music',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          if (resultsAsync.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (resultsAsync.hasError) {
            return Center(child: Text('Error: ${resultsAsync.error}'));
          }

          final results = resultsAsync.value!;

          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No results for "$query"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 90),
            children: [
              if (results.songs.isNotEmpty) ...[
                _SectionHeader(title: 'Songs', count: results.songs.length),
                ...results.songs.map(
                  (song) => _SongTile(song: song, allSongs: results.songs),
                ),
              ],
              if (results.albums.isNotEmpty) ...[
                _SectionHeader(title: 'Albums', count: results.albums.length),
                ...results.albums.map((album) => _AlbumTile(album: album)),
              ],
              if (results.artists.isNotEmpty) ...[
                _SectionHeader(title: 'Artists', count: results.artists.length),
                ...results.artists.map((artist) => _ArtistTile(artist: artist)),
              ],
              if (results.genres.isNotEmpty) ...[
                _SectionHeader(title: 'Genres', count: results.genres.length),
                ...results.genres.map((genre) => _GenreTile(genre: genre)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongTile extends ConsumerWidget {
  final SongModel song;
  final List<SongModel> allSongs;

  const _SongTile({required this.song, required this.allSongs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(playerProvider.select((s) => s.currentSong));
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));
    final isCurrentSong = currentSong?.path == song.path;

    return ListTile(
      tileColor: isCurrentSong
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      leading: CircleAvatar(
        backgroundColor: isCurrentSong
            ? Theme.of(context).colorScheme.primary
            : null,
        child: isCurrentSong
            ? Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              )
            : Text(
                song.title[0].toUpperCase(),
                style: const TextStyle(fontSize: 14),
              ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: isCurrentSong
            ? TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              )
            : null,
      ),
      subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(
        song.formattedDuration,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () {
        if (isCurrentSong) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NowPlayingScreen(),
              fullscreenDialog: true,
            ),
          );
        } else {
          ref
              .read(playerProvider.notifier)
              .playSong(allSongs, allSongs.indexOf(song));
        }
      },
    );
  }
}

class _AlbumTile extends StatelessWidget {
  final AlbumModel album;

  const _AlbumTile({required this.album});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.album,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(album.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${album.artist} · ${album.formattedSongCount}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album)),
      ),
    );
  }
}

class _ArtistTile extends StatelessWidget {
  final ArtistModel artist;

  const _ArtistTile({required this.artist});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          artist.name[0].toUpperCase(),
          style: const TextStyle(fontSize: 14),
        ),
      ),
      title: Text(artist.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(artist.subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ArtistDetailScreen(artist: artist)),
      ),
    );
  }
}

class _GenreTile extends StatelessWidget {
  final GenreModel genre;

  const _GenreTile({required this.genre});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.queue_music,
          color: Theme.of(context).colorScheme.onTertiaryContainer,
        ),
      ),
      title: Text(genre.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(genre.formattedSongCount),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GenreDetailScreen(genre: genre)),
      ),
    );
  }
}
