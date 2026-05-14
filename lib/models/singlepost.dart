import 'dart:convert';
import 'package:hive/hive.dart';

part 'singlepost.g.dart';

@HiveType(typeId: 1)
class SinglePost {
  SinglePost(
      {required this.title,
      required this.content,
      required this.img,
      required this.date,
      required this.category,
      Map<dynamic, dynamic>? acf})
      : acfJson = acf != null ? jsonEncode(acf) : null;

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

  /// Stored as JSON string so Hive serializes it reliably
  @HiveField(5)
  String? acfJson;

  /// Decoded acf Map — use this in the UI
  Map<String, dynamic>? get acf =>
      acfJson != null ? Map<String, dynamic>.from(jsonDecode(acfJson!)) : null;
}
