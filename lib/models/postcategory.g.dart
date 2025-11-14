// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'postcategory.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostCategoryAdapter extends TypeAdapter<PostCategory> {
  @override
  final int typeId = 2;

  @override
  PostCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostCategory(
      name: fields[0] as String,
      singlePosts: (fields[1] as List).cast<SinglePost>(),
    );
  }

  @override
  void write(BinaryWriter writer, PostCategory obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.singlePosts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
