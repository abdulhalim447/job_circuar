import 'package:hive/hive.dart';

part 'singlepost.g.dart';

@HiveType(typeId: 1)
class SinglePost {
  SinglePost(
      {required this.title,
      required this.content,
      required this.img,
      required this.date,
      required this.category});

  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  String img;

  @HiveField(3)
  int category;

  @HiveField(4)
  String date;
}
