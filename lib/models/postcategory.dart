import 'package:hive/hive.dart';
import 'package:job_circular/models/singlepost.dart';

part 'postcategory.g.dart';

@HiveType(typeId: 2)
class PostCategory {
  PostCategory({required this.name, required this.singlePosts});

  @HiveField(0)
  String name;

  @HiveField(1)
  List<SinglePost> singlePosts;
}
