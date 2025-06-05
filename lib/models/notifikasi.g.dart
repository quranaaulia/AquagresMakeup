// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifikasi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationItemAdapter extends TypeAdapter<NotificationItem> {
  @override
  final int typeId = 1;

  @override
  NotificationItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationItem(
      content: fields[0] as String,
      timestamp: fields[1] as DateTime,
      transactions: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.content)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.transactions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
