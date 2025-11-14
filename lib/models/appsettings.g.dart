// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appsettings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppsettingsAdapter extends TypeAdapter<Appsettings> {
  @override
  final int typeId = 4;

  @override
  Appsettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Appsettings(
      dark: fields[0] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Appsettings obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.dark);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppsettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
