import 'dart:async';

import 'package:hive/hive.dart';

import 'note_model.dart';

/// All Hive access lives here so screens never touch the box directly.
class NotesRepository {
  NotesRepository(this._box);

  final Box<Note> _box;

  static int _compare(Note a, Note b) {
    if (a.isPinned != b.isPinned) {
      return a.isPinned ? -1 : 1;
    }
    return b.updatedAt.compareTo(a.updatedAt);
  }

  List<Note> getAll({
    bool includeArchived = false,
    bool archivedOnly = false,
  }) {
    final notes = _box.values.where((note) {
      if (archivedOnly) {
        return note.isArchived;
      }
      return includeArchived || !note.isArchived;
    }).toList()
      ..sort(_compare);
    return notes;
  }

  Stream<List<Note>> watchAll({
    bool includeArchived = false,
    bool archivedOnly = false,
  }) async* {
    yield getAll(
      includeArchived: includeArchived,
      archivedOnly: archivedOnly,
    );
    yield* _box.watch().map(
      (_) => getAll(
        includeArchived: includeArchived,
        archivedOnly: archivedOnly,
      ),
    );
  }

  Note? getById(String id) {
    for (final note in _box.values) {
      if (note.id == id) {
        return note;
      }
    }
    return null;
  }

  Future<void> add(Note note) => _box.add(note);

  Future<void> update(Note note) async {
    final key = _keyOf(note.id);
    if (key != null) {
      await _box.put(key, note);
    }
  }

  Future<void> delete(String id) async {
    final key = _keyOf(id);
    if (key != null) {
      await _box.delete(key);
    }
  }

  Future<void> togglePin(String id) async {
    final key = _keyOf(id);
    final note = key == null ? null : _box.get(key);
    if (key != null && note != null) {
      await _box.put(
        key,
        note.copyWith(
          isPinned: !note.isPinned,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> setArchived(String id, {required bool archived}) async {
    final key = _keyOf(id);
    final note = key == null ? null : _box.get(key);
    if (key != null && note != null) {
      await _box.put(
        key,
        note.copyWith(
          isArchived: archived,
          isPinned: archived ? false : note.isPinned,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  dynamic _keyOf(String id) {
    for (final key in _box.keys) {
      if (_box.get(key)?.id == id) {
        return key;
      }
    }
    return null;
  }
}
