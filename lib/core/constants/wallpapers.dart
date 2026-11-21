import 'package:material_ui/material_ui.dart';

class WallpaperPreset {
  const WallpaperPreset({
    required this.name,
    required this.colors,
    required this.darkColors,
  });

  final String name;
  final List<Color> colors;
  final List<Color> darkColors;
}

const List<WallpaperPreset> wallpapers = <WallpaperPreset>[
  WallpaperPreset(
    name: 'Ocean',
    colors: <Color>[Color(0xFF2E6FD9), Color(0xFF6A4FD1), Color(0xFFD06FA8)],
    darkColors: <Color>[Color(0xFF07162F), Color(0xFF231042), Color(0xFF3B102F)],
  ),
  WallpaperPreset(
    name: 'Sunset',
    colors: <Color>[Color(0xFFFF8A5B), Color(0xFFE2548B), Color(0xFF7B3FA1)],
    darkColors: <Color>[Color(0xFF2B0F1B), Color(0xFF3B0E2C), Color(0xFF1C0B2E)],
  ),
  WallpaperPreset(
    name: 'Forest',
    colors: <Color>[Color(0xFF1E9E82), Color(0xFF2C7A8C), Color(0xFF5854B8)],
    darkColors: <Color>[Color(0xFF06221F), Color(0xFF082B33), Color(0xFF171B3D)],
  ),
  WallpaperPreset(
    name: 'Rose',
    colors: <Color>[Color(0xFFF3A6C0), Color(0xFFB986E8), Color(0xFF6C8FF0)],
    darkColors: <Color>[Color(0xFF2C1225), Color(0xFF241038), Color(0xFF101B3A)],
  ),
];
