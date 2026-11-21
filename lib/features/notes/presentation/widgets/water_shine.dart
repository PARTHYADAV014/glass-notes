import 'dart:math';

import 'package:flutter/material.dart';

/// Slow diagonal "water shine" for glass surfaces.
///
/// The highlight is a wide transparent -> white -> transparent gradient moved
/// across the card with an eased curve, so it accelerates and settles like a
/// real reflection instead of sliding at a constant speed. A much fainter
/// second highlight trails 30% behind, and each sweep picks a fresh 3-6s
/// duration to avoid a mechanical, repeating rhythm. Total opacity stays at
/// 0.15 (or lower) so text legibility is never affected.
class WaterShine extends StatefulWidget {
  const WaterShine({
    super.key,
    this.opacity = 0.15,
    this.minInterval = const Duration(seconds: 3),
    this.maxInterval = const Duration(seconds: 6),
  });

  final double opacity;
  final Duration minInterval;
  final Duration maxInterval;

  @override
  State<WaterShine> createState() => _WaterShineState();
}

class _WaterShineState extends State<WaterShine>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _nextInterval())
      ..addStatusListener(_onSweepEnd)
      ..forward();
  }

  Duration _nextInterval() {
    final min = widget.minInterval.inMilliseconds;
    final max = widget.maxInterval.inMilliseconds;
    final span = max > min ? max - min : 0;
    return Duration(milliseconds: min + _random.nextInt(span + 1));
  }

  void _onSweepEnd(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      _controller.duration = _nextInterval();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_onSweepEnd)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = _controller.value;
          final mainT = Curves.easeInOut.transform(progress);
          final trailingProgress = (progress - 0.3).clamp(0.0, 1.0);
          final trailingT = Curves.easeInOut.transform(trailingProgress);

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _highlight(progress: mainT, opacity: widget.opacity),
              if (progress > 0.3)
                _highlight(
                  progress: trailingT,
                  opacity: widget.opacity * 0.35,
                  isReflection: true,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _highlight({
    required double progress,
    required double opacity,
    bool isReflection = false,
  }) {
    final begin = Alignment(-1.6 + 3.2 * progress, isReflection ? -1.15 : -1.0);
    final end = Alignment(-0.2 + 3.2 * progress, isReflection ? 0.85 : 1.0);

    return Opacity(
      opacity: opacity,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: begin,
            end: end,
            colors: const <Color>[
              Color(0x00FFFFFF),
              Color(0xFFFFFFFF),
              Color(0x00FFFFFF),
            ],
            stops: const <double>[0.12, 0.5, 0.88],
          ).createShader(bounds);
        },
        child: const ColoredBox(color: Colors.white),
      ),
    );
  }
}
