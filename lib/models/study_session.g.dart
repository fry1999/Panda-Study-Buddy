// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudySessionAdapter extends TypeAdapter<StudySession> {
  @override
  final int typeId = 0;

  @override
  StudySession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudySession(
      id: fields[0] as String,
      userId: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime?,
      durationSeconds: fields[4] as int,
      sessionType: fields[5] as String,
      bambooEarned: fields[6] as int,
      completed: fields[7] as bool,
      partnerId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StudySession obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.durationSeconds)
      ..writeByte(5)
      ..write(obj.sessionType)
      ..writeByte(6)
      ..write(obj.bambooEarned)
      ..writeByte(7)
      ..write(obj.completed)
      ..writeByte(8)
      ..write(obj.partnerId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudySessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
