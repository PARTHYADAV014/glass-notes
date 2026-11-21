import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../data/note_model.dart';
import '../data/notes_repository.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(Hive.box<Note>('notes'));
});

/// Active notes, pinned first.
final notesProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(notesRepositoryProvider).watchAll();
});

/// Includes archived notes for the Archive view.
final archivedNotesProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(notesRepositoryProvider).watchAll(archivedOnly: true);
});
