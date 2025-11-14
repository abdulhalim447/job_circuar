import 'package:hive/hive.dart';

part 'appsettings.g.dart';

@HiveType(typeId: 4)
class Appsettings {
  Appsettings({required this.dark});

  @HiveField(0)
  bool dark;
}
