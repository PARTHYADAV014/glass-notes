import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/settings_sheet.dart';
import 'water_shine.dart';

/// Cached once for the whole app: BackdropFilter recomputes this cheaply,
/// but reusing one instance avoids reallocating the filter per card.
final ui.ImageFilter kGlassBlur = ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18);

/// The core Glass Notes surface.
///
/// Shadow lives on the outer Container so it is not clipped; the inner
/// ClipRRect + BackdropFilter produce the frosted panel, and the WaterShine
/// layer adds the slow moving reflection on top of the translucent fill.
class GlassCard extends ConsumerWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.showShine = true,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool showShine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(settingsProvider).darkMode;
    final borderAlpha = isDark ? 0.55 : 0.35;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: kGlassBlur,
            child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: Colors.white.withValues(alpha: 0.12),
              highlightColor: Colors.white.withValues(alpha: 0.06),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Color(0x40FFFFFF),
                            Color(0x1AFFFFFF),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: borderAlpha),
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                  ),
                  if (showShine)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: const WaterShine(),
                      ),
                    ),
                  Padding(padding: padding, child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  }
}
