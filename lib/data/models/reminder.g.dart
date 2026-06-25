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
      description: fields[2] as String?,
      type: fields[3] as ReminderType,
      scheduledAt: fields[4] as DateTime,
      repeat: fields[5] as RepeatInterval?,
      priority: fields[6] as PriorityLevel,
      isCompleted: fields[7] == null ? false : fields[7] as bool,
      acknowledgedAt: fields[8] as DateTime?,
      snoozeCount: fields[9] == null ? 0 : (fields[9] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.scheduledAt)
      ..writeByte(5)
      ..write(obj.repeat)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.isCompleted)
      ..writeByte(8)
      ..write(obj.acknowledgedAt)
      ..writeByte(9)
      ..write(obj.snoozeCount);
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

class ReminderTypeAdapter extends TypeAdapter<ReminderType> {
  @override
  final typeId = 2;

  @override
  ReminderType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReminderType.medication;
      case 1:
        return ReminderType.deadline;
      case 2:
        return ReminderType.bill;
      case 3:
        return ReminderType.custom;
      default:
        return ReminderType.medication;
    }
  }

  @override
  void write(BinaryWriter writer, ReminderType obj) {
    switch (obj) {
      case ReminderType.medication:
        writer.writeByte(0);
      case ReminderType.deadline:
        writer.writeByte(1);
      case ReminderType.bill:
        writer.writeByte(2);
      case ReminderType.custom:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RepeatIntervalAdapter extends TypeAdapter<RepeatInterval> {
  @override
  final typeId = 3;

  @override
  RepeatInterval read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RepeatInterval.everyFourHours;
      case 1:
        return RepeatInterval.everySixHours;
      case 2:
        return RepeatInterval.everyEightHours;
      case 3:
        return RepeatInterval.everyTwelveHours;
      case 4:
        return RepeatInterval.daily;
      case 5:
        return RepeatInterval.weekly;
      case 6:
        return RepeatInterval.monthly;
      default:
        return RepeatInterval.everyFourHours;
    }
  }

  @override
  void write(BinaryWriter writer, RepeatInterval obj) {
    switch (obj) {
      case RepeatInterval.everyFourHours:
        writer.writeByte(0);
      case RepeatInterval.everySixHours:
        writer.writeByte(1);
      case RepeatInterval.everyEightHours:
        writer.writeByte(2);
      case RepeatInterval.everyTwelveHours:
        writer.writeByte(3);
      case RepeatInterval.daily:
        writer.writeByte(4);
      case RepeatInterval.weekly:
        writer.writeByte(5);
      case RepeatInterval.monthly:
        writer.writeByte(6);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatIntervalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
