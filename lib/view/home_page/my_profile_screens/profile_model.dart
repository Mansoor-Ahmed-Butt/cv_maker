import 'package:hive/hive.dart';
part 'profile_model.g.dart';

@HiveType(typeId: 1)
class ProfileModel extends HiveObject {
  @HiveField(0)
  String fullName;

  @HiveField(1)
  String jobTitle;

  @HiveField(2)
  String email;

  @HiveField(3)
  String phone;

  @HiveField(4)
  String location;

  @HiveField(5)
  String bio;

  @HiveField(6)
  String website;

  @HiveField(7)
  String linkedin;

  @HiveField(8)
  String github;

  @HiveField(9)
  String avatarPath; // local file path for picked image

  ProfileModel({
    this.fullName = '',
    this.jobTitle = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.bio = '',
    this.website = '',
    this.linkedin = '',
    this.github = '',
    this.avatarPath = '',
  });
}
