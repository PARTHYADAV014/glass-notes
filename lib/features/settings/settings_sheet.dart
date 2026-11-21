import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../../core/constants/wallpapers.dart';
import '../notes/presentation/widgets/glass_card.dart';

class AppSettings {
  const AppSettings({
    this.darkMode = false,
    this.wallpaperIndex = 0,
  });

  final bool darkMode;
  final int wallpaperIndex;

  AppSettings copyWith({
    bool? darkMode,
    int? wallpaperIndex,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      wallpaperIndex: wallpaperIndex ?? this.wallpaperIndex,
    );
  }
}

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController() : super(_read()) {
    _box = Hive.box<dynamic>('settings');
  }

  late final Box<dynamic> _box;

  static AppSettings _read() {
    final box = Hive.box<dynamic>('settings');
    return AppSettings(
      darkMode: box.get('darkMode') as bool? ?? false,
      wallpaperIndex: box.get('wallpaperIndex') as int? ?? 0,
    );
  }

  void setDarkMode(bool value) {
    state = state.copyWith(darkMode: value);
    unawaited(_box.put('darkMode', value));
  }

  void setWallpaper(int index) {
    state = state.copyWith(wallpaperIndex: index);
    unawaited(_box.put('wallpaperIndex', index));
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController();
});

Future<void> showGlassSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: const SettingsSheet(),
      );
    },
  );
}

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Settings',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              const Icon(Icons.dark_mode_outlined, color: Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Dark mode',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                ),
              ),
              Switch(
                value: settings.darkMode,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setDarkMode(value);
                },
              ),
            ],
          ),
          const Divider(height: 26),
          Text(
            'Wallpaper',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (var i = 0; i < wallpapers.length; i++)
                _WallpaperSwatch(
                  index: i,
                  selected: settings.wallpaperIndex == i,
                  onTap: () {
                    ref.read(settingsProvider.notifier).setWallpaper(i);
                  },
                ),
            ],
          ),
          const Divider(height: 26),
          Row(
            children: <Widget>[
              const Icon(Icons.info_outline, color: Colors.white70, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Glass Notes 1.0.0\nOffline. Private. Yours.',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WallpaperSwatch extends StatelessWidget {
  const _WallpaperSwatch({
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preset = wallpapers[index];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: preset.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withValues(alpha: 0.25),
            width: selected ? 2.4 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                preset.name,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  shadows: const <Shadow>[
                    Shadow(color: Colors.black45, blurRadius: 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
