import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:job_circular/models/favouritepost.dart';
import 'package:job_circular/models/singlepost.dart';

class FavouritesProvider extends ChangeNotifier {
  Box<FavouritePost>? _favouritesBox;
  Box<FavouritePost> get favouritesBox {
    _favouritesBox ??= Hive.box<FavouritePost>('favourites');
    return _favouritesBox!;
  }

  List<SinglePost> _favourites = [];

  FavouritesProvider() {
    // Delay initialization to ensure Hive boxes are open
    Future.microtask(() {
      _loadFavourites();
    });
  }

  List<SinglePost> get favourites => _favourites;

  int get favouritesCount => _favourites.length;

  void _loadFavourites() {
    try {
      _favourites = [];
      for (int i = 0; i < favouritesBox.length; i++) {
        final fav = favouritesBox.getAt(i);
        if (fav is FavouritePost) {
          _favourites.add(fav.singlePosts);
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error loading favourites: $e');
    }
  }

  bool isFavourite(String title) {
    return _favourites.any((post) => post.title == title);
  }

  void addFavourite(SinglePost post) {
    if (!isFavourite(post.title)) {
      favouritesBox.add(FavouritePost(singlePosts: post));
      _favourites.add(post);
      notifyListeners();
    }
  }

  void removeFavourite(String title) {
    try {
      // Find and remove from Hive
      for (int i = 0; i < favouritesBox.length; i++) {
        final fav = favouritesBox.getAt(i);
        if (fav is FavouritePost && fav.singlePosts.title == title) {
          favouritesBox.deleteAt(i);
          break;
        }
      }

      // Remove from local list
      _favourites.removeWhere((post) => post.title == title);
      notifyListeners();
    } catch (e) {
      print('Error removing favourite: $e');
    }
  }

  void toggleFavourite(SinglePost post) {
    if (isFavourite(post.title)) {
      removeFavourite(post.title);
    } else {
      addFavourite(post);
    }
  }

  void clearAllFavourites() {
    favouritesBox.clear();
    _favourites.clear();
    notifyListeners();
  }
}
