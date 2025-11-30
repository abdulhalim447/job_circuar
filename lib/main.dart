import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:job_circular/bottombar.dart';
import 'package:job_circular/models/favouritepost.dart';
import 'package:job_circular/utis/models.dart';
import 'package:provider/provider.dart';

import 'models/appsettings.dart';
import 'models/postcategory.dart';
import 'models/singlepost.dart';
import 'providers/categories_provider.dart';
import 'providers/favourites_provider.dart';
import 'providers/posts_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PostCategoryAdapter());
  Hive.registerAdapter(SinglePostAdapter());
  Hive.registerAdapter(FavouritePostAdapter());
  Hive.registerAdapter(AppsettingsAdapter());
  categories = await Hive.openBox<PostCategory>('category');
  singlePost = await Hive.openBox<SinglePost>('posts');
  favourites = await Hive.openBox<FavouritePost>('favourites');
  settings = await Hive.openBox<Appsettings>('settings');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostsProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => FavouritesProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    nextScreen();
  }

  void nextScreen() {
    Timer(Duration(seconds: 2), () {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: 'Job Circular Notice BD',
          debugShowCheckedModeBanner: false,
          themeMode: settingsProvider.themeMode,
          theme: ThemeData.light().copyWith(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
          darkTheme: ThemeData.dark().copyWith(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
          home: !loading
              ? BottomBar()
              : Scaffold(
                  body: SafeArea(
                    child: Center(child: Image.asset('img/splash.jpg', fit: BoxFit.cover)),
                  ),
                ),
        );
      },
    );
  }

  // Future<void> getCategories() async {
  //   var res1 = await http.get(Uri.parse(
  //       'https://job_circularnoticebd.com/wp-json/wp/v2/categories?_fields=id,name'));
  //   var cats = jsonDecode(res1.body);
  //
  //   for (var cat in cats) {
  //     List<SinglePost> postss = [];
  //     for (int i = 0; i < singlePost.length; i++) {
  //       var p = singlePost.getAt(i);
  //       if (p!.category == cat['id']) {
  //         postss.add(p);
  //         // print('${p!.category}+${cat['id']}');
  //       }
  //     }
  //     categories.put(
  //         cat['id'], PostCategory(name: cat['name'], singlePosts: postss));
  //   }
  // }

  // void getPosts() async {
  //   int i = 1;
  //   while (true) {
  //     var response = await http.get(Uri.parse(
  //         'https://job_circularnoticebd.com/wp-json/wp/v2/posts?page=1&limit=10'));
  //     var data = jsonDecode(response.body);
  //     print(data);
  //     // if (data.length == 0) {
  //     //   break;
  //     // }
  //
  //     // for (var post in data) {
  //     //   print(post);
  //     //   singlePost.put(
  //     //       post['id'],
  //     //       SinglePost(
  //     //         title: post['title']['rendered'],
  //     //         content: post['content']['rendered'],
  //     //         img: post['jetpack_featured_media_url'],
  //     //         category: post['categories'][0],
  //     //       ));
  //     // }
  //     i++;
  //     print('number:${i}');
  //   }
  //   // await getCategories();
  // }
}
