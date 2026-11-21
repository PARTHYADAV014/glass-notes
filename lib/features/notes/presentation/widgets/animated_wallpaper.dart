import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/wallpapers.dart';
import '../../../settings/settings_sheet.dart';

/// Full-screen animated wallpaper.
///
/// Crossfades between the four presets over 800 ms (Curves.easeInOut) and
/// keeps a slow 20 s gradient position shift running even while idle, so the
/// background never looks frozen. [blur] is used by the editor screen.
class AnimatedWallpaper extends ConsumerStatefulWidget {
  const AnimatedWallpaper({super.key, this.blur = 0});

  final double blur;

  @override
  ConsumerState<AnimatedWallpaper> createState() => _AnimatedWallpaperState();
}

class _AnimatedWallpaperState extends ConsumerState<AnimatedWallpaper>
    with TickerProviderStateMixin {
  late final AnimationController _shiftController;
  late final AnimationController _fadeController;

  int _currentIndex = 0;
  int _previousIndex = 0;
  bool _isCrossfading = false;

  @override
  void initState() {
    super.initState();
    _shiftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    final initial = ref
        .read(settingsProvider)
        .wallpaperIndex
        .clamp(0, wallpapers.length - 1);
    _currentIndex = initial;
    _previousIndex = initial;

    ref.listen(settingsProvider, (previous, next) {
      final newIndex = next.wallpaperIndex.clamp(0, wallpapers.length - 1);
      if (newIndex != _currentIndex) {
        _previousIndex = _currentIndex;
        _currentIndex = newIndex;
        _isCrossfading = true;
        _fadeController.forward(from: 0).then((_) {
          if (mounted) {
            setState(() => _isCrossfading = false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _shiftController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _layer(List<Color> colors, double opacity, bool isDark, double shift) {
    final angle = shift * 2 * math.pi;
    final begin = Alignment(
      0.3 * math.cos(angle) - 0.85,
      0.25 * math.sin(angle) - 0.9,
    );
    final end = Alignment(
      -0.3 * math.cos(angle) + 0.85,
      -0.25 * math.sin(angle) + 0.9,
    );
    final glow = Alignment(
      0.6 * math.cos(angle + 1.0),
      0.4 * math.sin(angle + 1.0),
    );

    final scene = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: colors,
              stops: const <double>[0.0, 0.5, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: glow,
              radius: 0.9,
              colors: <Color>[
                Colors.white.withOpacity(isDark ? 0.07 : 0.16),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );

    return Opacity(opacity: opacity, child: scene);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = settings.darkMode;
    final currentColors = isDark
        ? wallpapers[_currentIndex].darkColors
        : wallpapers[_currentIndex].colors;
    final previousColors = isDark
        ? wallpapers[_previousIndex].darkColors
        : wallpapers[_previousIndex].colors;

    final scene = AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_shiftController, _fadeController]),
      builder: (context, _) {
        final shift = _shiftController.value;
        final fade = Curves.easeInOut.transform(_fadeController.value);

        final stack = Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (_isCrossfading)
              _layer(previousColors, 1 - fade, isDark, shift),
            _layer(
              currentColors,
              _isCrossfading ? fade : 1.0,
              isDark,
              shift,
            ),
          ],
        );
        return stack;
      },
    );

    if (widget.blur <= 0) {
      return scene;
    }
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: widget.blur,
        sigmaY: widget.blur,
      ),
      child: scene,
    );
  }
}
