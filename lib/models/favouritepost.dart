import 'package:hive/hive.dart';
import 'package:job_circular/models/singlepost.dart';

part 'favouritepost.g.dart';

@HiveType(typeId: 3)
class FavouritePost {
  FavouritePost({required this.singlePosts});

  @HiveField(1)
  SinglePost singlePosts;
}
