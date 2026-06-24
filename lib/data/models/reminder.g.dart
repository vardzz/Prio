// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final typeId = 1;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String,
      title: fields[1] as String,
      scheduledAt: fields[2] as DateTime,
      priority: fields[3] as PriorityLevel,
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.scheduledAt)
      ..writeByte(3)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PriorityLevelAdapter extends TypeAdapter<PriorityLevel> {
  @override
  final typeId = 0;

  @override
  PriorityLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PriorityLevel.normal;
      case 1:
        return PriorityLevel.high;
      case 2:
        return PriorityLevel.critical;
      default:
        return PriorityLevel.normal;
    }
  }

  @override
  void write(BinaryWriter writer, PriorityLevel obj) {
    switch (obj) {
      case PriorityLevel.normal:
        writer.writeByte(0);
      case PriorityLevel.high:
        writer.writeByte(1);
      case PriorityLevel.critical:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriorityLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
