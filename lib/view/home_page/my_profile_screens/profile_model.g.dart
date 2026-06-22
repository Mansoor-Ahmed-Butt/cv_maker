// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileModelAdapter extends TypeAdapter<ProfileModel> {
  @override
  final int typeId = 1;

  @override
  ProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileModel(
      fullName: fields[0] as String,
      jobTitle: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String,
      location: fields[4] as String,
      bio: fields[5] as String,
      website: fields[6] as String,
      linkedin: fields[7] as String,
      github: fields[8] as String,
      avatarPath: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.fullName)
      ..writeByte(1)
      ..write(obj.jobTitle)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.bio)
      ..writeByte(6)
      ..write(obj.website)
      ..writeByte(7)
      ..write(obj.linkedin)
      ..writeByte(8)
      ..write(obj.github)
      ..writeByte(9)
      ..write(obj.avatarPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
