// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyStatsAdapter extends TypeAdapter<DailyStats> {
  @override
  final int typeId = 2;

  @override
  DailyStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyStats(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      totalFocusTimeSeconds: fields[2] as int,
      sessionsCompleted: fields[3] as int,
      bambooEarned: fields[4] as int,
      streakCount: fields[5] as int,
      userId: fields[6] as String,
      partnerId: fields[7] as String?,
      partnerFocusTimeSeconds: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyStats obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.totalFocusTimeSeconds)
      ..writeByte(3)
      ..write(obj.sessionsCompleted)
      ..writeByte(4)
      ..write(obj.bambooEarned)
      ..writeByte(5)
      ..write(obj.streakCount)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.partnerId)
      ..writeByte(8)
      ..write(obj.partnerFocusTimeSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
