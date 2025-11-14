// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'singlepost.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SinglePostAdapter extends TypeAdapter<SinglePost> {
  @override
  final int typeId = 1;

  @override
  SinglePost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SinglePost(
      title: fields[0] as String,
      content: fields[1] as String,
      img: fields[2] as String,
      date: fields[4] as String,
      category: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SinglePost obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.img)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SinglePostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
