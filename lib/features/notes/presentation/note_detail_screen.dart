import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../data/note_model.dart';
import '../data/notes_repository.dart';
import '../providers/notes_provider.dart';
import 'widgets/animated_wallpaper.dart';
import 'widgets/glass_card.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  const NoteDetailScreen({super.key, this.noteId});

  final String? noteId;

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  late final NotesRepository _repository;
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  final FocusNode _titleFocus = FocusNode();

  Timer? _saveTimer;
  Note? _note;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _repository = ref.read(notesRepositoryProvider);
    _note = widget.noteId == null
        ? null
        : _repository.getById(widget.noteId!);

    _titleController = TextEditingController(text: _note?.title ?? '');
    _bodyController = TextEditingController(text: _note?.body ?? '');
    _titleController.addListener(_scheduleSave);
    _bodyController.addListener(_scheduleSave);

    if (widget.noteId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _titleFocus.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    if (_dirty) {
      _persist();
    }
    _titleController.removeListener(_scheduleSave);
    _bodyController.removeListener(_scheduleSave);
    _titleController.dispose();
    _bodyController.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  void _scheduleSave() {
    _dirty = true;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), _persist);
  }

  void _persist() {
    _saveTimer?.cancel();
    final title = _titleController.text;
    final body = _bodyController.text;
    final current = _note;

    if (current == null) {
      if (title.trim().isEmpty && body.trim().isEmpty) {
        _dirty = false;
        return;
      }
      final note = Note(
        id: const Uuid().v4(),
        title: title,
        body: body,
        updatedAt: DateTime.now(),
      );
      unawaited(_repository.add(note));
      _note = note;
    } else {
      final updated = current.copyWith(
        title: title,
        body: body,
        updatedAt: DateTime.now(),
      );
      unawaited(_repository.update(updated));
      _note = updated;
    }
    _dirty = false;
  }

  Future<void> _togglePin() async {
    _persist();
    final note = _note;
    if (note == null) {
      return;
    }
    await _repository.togglePin(note.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _note = _repository.getById(note.id);
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Delete this note?',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This cannot be undone.',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      final note = _note;
      if (note != null) {
        await _repository.delete(note.id);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPinned = _note?.isPinned ?? false;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: <Widget>[
        const Positioned.fill(child: AnimatedWallpaper(blur: 14)),
        Positioned.fill(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              leading: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                isPinned ? 'Pinned note' : 'Note',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: <Widget>[
                IconButton(
                  tooltip: isPinned ? 'Unpin' : 'Pin',
                  color: isPinned ? const Color(0xFFFFD77A) : Colors.white,
                  icon: Icon(
                    isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                  ),
                  onPressed: _togglePin,
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: _confirmDelete,
                ),
                const SizedBox(width: 6),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 18,
                  right: 18,
                  top: 8,
                  bottom: bottomInset + 18,
                ),
                child: GlassCard(
                  borderRadius: 28,
                  padding: const EdgeInsets.all(20),
                  child: SizedBox.expand(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextField(
                          controller: _titleController,
                          focusNode: _titleFocus,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            shadows: const <Shadow>[
                              Shadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) {
                            FocusScope.of(context).nextFocus();
                          },
                          decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Divider(height: 22),
                        Expanded(
                          child: TextField(
                            controller: _bodyController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 16,
                              height: 1.45,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Start writing...',
                              hintStyle: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: Colors.white60,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Edited ${_formatTime(_note?.updatedAt ?? DateTime.now())}',
                              style: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inSeconds < 60) {
      return 'just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} h ago';
    }
    return '${time.day}/${time.month}/${time.year}';
  }
}
