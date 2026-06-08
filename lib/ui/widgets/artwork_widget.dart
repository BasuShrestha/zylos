import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/utils/artwork_cache.dart';

class ArtworkWidget extends StatefulWidget {
  final String artworkPath;
  final double size;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final double fallbackIconSize;

  const ArtworkWidget({
    super.key,
    required this.artworkPath,
    required this.size,
    this.borderRadius,
    this.fallbackIcon = Icons.music_note,
    this.fallbackIconSize = 24,
  });

  @override
  State<ArtworkWidget> createState() => _ArtworkWidgetState();
}

class _ArtworkWidgetState extends State<ArtworkWidget> {
  Uint8List? _bytes;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  @override
  void didUpdateWidget(ArtworkWidget old) {
    super.didUpdateWidget(old);
    if (old.artworkPath != widget.artworkPath) {
      _loaded = false;
      _bytes = null;
      _loadArtwork();
    }
  }

  Future<void> _loadArtwork() async {
    if (widget.artworkPath.isEmpty) {
      if (mounted) setState(() => _loaded = true);
      return;
    }

    // Check LRU cache first
    if (ArtworkCache.instance.has(widget.artworkPath)) {
      final cached = ArtworkCache.instance.get(widget.artworkPath);
      if (mounted) {
        setState(() {
          _bytes = cached;
          _loaded = true;
        });
      }
      return;
    }

    // Load from disk
    try {
      final file = File(widget.artworkPath);
      if (file.existsSync()) {
        final bytes = await file.readAsBytes();
        ArtworkCache.instance.put(widget.artworkPath, bytes);
        if (mounted) {
          setState(() {
            _bytes = bytes;
            _loaded = true;
          });
        }
        return;
      }
    } catch (_) {}

    ArtworkCache.instance.put(widget.artworkPath, null);
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(8);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipRRect(borderRadius: radius, child: _buildContent(context)),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (!_loaded) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      );
    }

    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        gaplessPlayback: true, // no flicker when source changes
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    }

    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        widget.fallbackIcon,
        size: widget.fallbackIconSize,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
