import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../settings/settings_sheet.dart';
import '../data/note_model.dart';
import '../providers/notes_provider.dart';
import 'note_detail_screen.dart';
import 'widgets/animated_wallpaper.dart';
import 'widgets/glass_card.dart';
import 'widgets/note_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final notesAsync = _showArchived
        ? ref.watch(archivedNotesProvider)
        : ref.watch(notesProvider);
    final notes = notesAsync.value ?? const <Note>[];

    return Stack(
      children: <Widget>[
        const Positioned.fill(child: AnimatedWallpaper()),
        Positioned.fill(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              leading: IconButton(
                tooltip: _showArchived ? 'Back to notes' : 'Archive',
                icon: Icon(
                  _showArchived
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.archive_outlined,
                ),
                onPressed: () {
                  setState(() => _showArchived = !_showArchived);
                },
              ),
              title: Text(
                'Glass Notes',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: <Widget>[
                IconButton(
                  tooltip: 'Settings',
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: () => showGlassSettingsSheet(context),
                ),
                const SizedBox(width: 6),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NoteDetailScreen(),
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.45), width: 1.2),
              ),
              child: const Icon(Icons.add_rounded, size: 30),
            ).animate().scale(
                  duration: 320.ms,
                  curve: Curves.elasticOut,
                ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _showArchived ? 'Archive' : 'Notes',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        shadows: const <Shadow>[
                          Shadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.08, end: 0),
                    const SizedBox(height: 4),
                    Text(
                      _showArchived
                          ? '(${notes.length}) archived notes'
                          : '(${notes.length}) notes',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Expanded(
                      child: notes.isEmpty
                          ? GlassCard(
                              padding: const EdgeInsets.all(28),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    _showArchived
                                        ? Icons.archive_outlined
                                        : Icons.sticky_note_2_outlined,
                                    size: 42,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    _showArchived
                                        ? 'No archived notes.'
                                        : 'No notes yet. Tap + to add.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: notes.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                return NoteTile(
                                  note: notes[index],
                                  archived: _showArchived,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
