// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favouritepost.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavouritePostAdapter extends TypeAdapter<FavouritePost> {
  @override
  final int typeId = 3;

  @override
  FavouritePost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavouritePost(
      singlePosts: fields[1] as SinglePost,
    );
  }

  @override
  void write(BinaryWriter writer, FavouritePost obj) {
    writer
      ..writeByte(1)
      ..writeByte(1)
      ..write(obj.singlePosts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavouritePostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
