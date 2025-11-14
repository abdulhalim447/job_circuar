import 'package:hive/hive.dart';
import 'package:job_circular/models/appsettings.dart';

import '../models/favouritepost.dart';
import '../models/postcategory.dart';
import '../models/singlepost.dart';

late Box<SinglePost> singlePost;
late Box<PostCategory> categories;
late Box<FavouritePost> favourites;
late Box<Appsettings> settings;
