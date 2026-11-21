// Hand-written Hive adapter: no build_runner step is required.

part of 'note_model.dart';

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };

    return Note(
      id: fields[0] as String,
      title: fields[1] as String? ?? '',
      body: fields[2] as String? ?? '',
      createdAt: fields[3] as DateTime? ?? DateTime.now(),
      updatedAt: fields[4] as DateTime? ?? DateTime.now(),
      isPinned: fields[5] as bool? ?? false,
      isArchived: fields[6] as bool? ?? false,
      colorTag: fields[7] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.isPinned)
      ..writeByte(6)
      ..write(obj.isArchived)
      ..writeByte(7)
      ..write(obj.colorTag);
  }
}
