import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/player_provider.dart';

// ─────────────────────────────────────────────
// ConsumerStatefulWidget is needed here because
// we need both an AnimationController (requires
// a State + TickerProvider) AND access to ref.
// Use this whenever you need both local animation
// state and Riverpod providers together.
// ─────────────────────────────────────────────
class SeekBar extends ConsumerStatefulWidget {
  const SeekBar({super.key});

  @override
  ConsumerState<SeekBar> createState() => _WaveSeekBarState();
}

class _WaveSeekBarState extends ConsumerState<SeekBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    // Continuous animation that drives the wave phase
    // Duration of 1s means the wave completes one
    // full cycle per second — feels natural
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(playerProvider.select((s) => s.position));
    final duration = ref.watch(playerProvider.select((s) => s.duration));
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));

    // Start/stop wave animation based on playing state
    if (isPlaying && !_waveController.isAnimating) {
      _waveController.repeat();
    } else if (!isPlaying && _waveController.isAnimating) {
      _waveController.stop();
    }

    final progress = duration.inMilliseconds == 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // ── Wave canvas — tappable for seeking ──
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final localDx = box.globalToLocal(details.globalPosition).dx;
              final newProgress = (localDx / box.size.width).clamp(0.0, 1.0);
              ref
                  .read(playerProvider.notifier)
                  .seekTo(
                    Duration(
                      milliseconds: (newProgress * duration.inMilliseconds)
                          .toInt(),
                    ),
                  );
            },
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) {
                return SizedBox(
                  height: 48,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _WavePainter(
                      progress: progress,
                      // phase drives the horizontal scroll of the wave
                      phase: _waveController.value * 2 * pi,
                      isPlaying: isPlaying,
                      playedColor: Theme.of(context).colorScheme.primary,
                      remainingColor: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.25),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Timestamps ───────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _format(position),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                _format(duration),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final double phase;
  final bool isPlaying;
  final Color playedColor;
  final Color remainingColor;

  const _WavePainter({
    required this.progress,
    required this.phase,
    required this.isPlaying,
    required this.playedColor,
    required this.remainingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final progressX = progress * size.width;

    // Wave shape parameters
    final amplitude = isPlaying ? 6.0 : 0.0;
    final wavelength = 30.0;

    final playedPaint = Paint()
      ..color = playedColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final remainingPaint = Paint()
      ..color = remainingColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // ── Played portion ───────────────────────────
    final playedPath = Path();
    for (double x = 0; x <= progressX; x++) {
      final y = centerY + amplitude * sin((x / wavelength * 2 * pi) + phase);
      x == 0 ? playedPath.moveTo(x, y) : playedPath.lineTo(x, y);
    }
    if (progressX > 0) canvas.drawPath(playedPath, playedPaint);

    // ── Remaining portion — smaller amplitude ────
    final remainingAmplitude = isPlaying ? 2.5 : 0.0;
    final remainingPath = Path();
    for (double x = progressX; x <= size.width; x++) {
      final y =
          centerY + remainingAmplitude * sin((x / wavelength * 2 * pi) + phase);
      x == progressX ? remainingPath.moveTo(x, y) : remainingPath.lineTo(x, y);
    }
    canvas.drawPath(remainingPath, remainingPaint);

    // ── Thumb dot at progress point ──────────────
    final thumbY =
        centerY + amplitude * sin((progressX / wavelength * 2 * pi) + phase);
    canvas.drawCircle(
      Offset(progressX, thumbY),
      6.0,
      Paint()..color = playedColor,
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.progress != progress ||
      old.phase != phase ||
      old.isPlaying != isPlaying;
}
