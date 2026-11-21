import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/note_model.dart';
import '../../providers/notes_provider.dart';
import '../note_detail_screen.dart';
import 'glass_card.dart';

class NoteTile extends ConsumerWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.archived,
  });

  final Note note;
  final bool archived;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(notesRepositoryProvider);

    return Slidable(
      key: ValueKey<String>(note.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.26,
        children: <Widget>[
          CustomSlidableAction(
            onPressed: (_) async {
              if (archived) {
                await repository.setArchived(note.id, archived: false);
              } else {
                await repository.togglePin(note.id);
              }
            },
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            child: _glassAction(
              icon: archived
                  ? Icons.unarchive_outlined
                  : (note.isPinned
                      ? Icons.push_pin_outlined
                      : Icons.push_pin_outlined),
              label: archived ? 'Restore' : (note.isPinned ? 'Unpin' : 'Pin'),
              tint: archived ? const Color(0xFF9EE7FF) : const Color(0xFFFFD77A),
            ),
          ),
        ],
      ),
      endActionPane: archived
          ? null
          : ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.26,
              children: <Widget>[
                CustomSlidableAction(
                  onPressed: (_) async {
                    await repository.setArchived(note.id, archived: true);
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Note archived'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            repository.setArchived(note.id, archived: false);
                          },
                        ),
                      ),
                    );
                  },
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  child: _glassAction(
                    icon: Icons.archive_outlined,
                    label: 'Archive',
                    tint: const Color(0xFFFF9AAE),
                  ),
                ),
              ],
            ),
      child: GlassCard(
        padding: EdgeInsets.zero,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => NoteDetailScreen(noteId: note.id),
            ),
          );
        },
        child: Stack(
          children: <Widget>[
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color(0x00FFFFFF),
                      Color(0x33FFFFFF),
                      Color(0x00FFFFFF),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: <Color>[Color(0x66FFFFFF), Color(0x22FFFFFF)],
                      ),
                      border:
                          Border.all(color: Colors.white.withValues(alpha: 0.35)),
                    ),
                    child: Icon(
                      note.isPinned
                          ? Icons.push_pin_rounded
                          : Icons.sticky_note_2_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                note.title.trim().isEmpty
                                    ? 'Untitled note'
                                    : note.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  shadows: const <Shadow>[
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (note.isPinned)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.push_pin_rounded,
                                  size: 13,
                                  color: Color(0xFFFFD77A),
                                ),
                              ),
                            const SizedBox(width: 6),
                            Text(
                              _relativeTime(note.updatedAt),
                              style: GoogleFonts.inter(
                                color: const Color(0x8AFFFFFF),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          note.body.trim().isEmpty
                              ? 'No additional text'
                              : note.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.04, end: 0),
    );
  }

  /// One glass action sitting on a blurred glass panel.
  Widget _glassAction({
    required IconData icon,
    required String label,
    required Color tint,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: <Color>[
                tint.withValues(alpha: 0.40),
                tint.withValues(alpha: 0.12),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _relativeTime(DateTime time) {
  final difference = DateTime.now().difference(time);
  if (difference.isNegative || difference.inSeconds < 60) {
    return 'Just now';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} h ago';
  }
  if (difference.inDays == 1) {
    return 'Yesterday';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  }
  const months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[time.month - 1]} ${time.day}';
}
