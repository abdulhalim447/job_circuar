import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class PostsProvider extends ChangeNotifier {
  // Constants
  static const int _cacheLimit = 5;
  static const Duration _cacheTTL = Duration(hours: 1);

  // Posts by category (Limited Cache)
  LinkedHashMap<int, List<dynamic>> _postsByCategory = LinkedHashMap();
  Map<int, DateTime?> _cacheTimestamps = {};
  Map<int, bool> _loadingByCategory = {};
  Map<int, int> _currentPageByCategory = {};
  Map<int, bool> _hasMorePostsByCategory = {};

  // Search results
  List<dynamic> _searchResults = [];
  bool _searchLoading = false;

  // Hive box
  Box? _postsBox;
  Box get postsBox {
    _postsBox ??= Hive.box('posts_cache');
    return _postsBox!;
  }

  PostsProvider() {
    // Delay initialization to ensure Hive boxes are open
    Future.microtask(() {
      _loadCachedPosts();
    });
  }

  // Getters
  List<dynamic> getPostsByCategory(int categoryId) {
    return _postsByCategory[categoryId] ?? [];
  }

  bool isLoadingCategory(int categoryId) {
    return _loadingByCategory[categoryId] ?? false;
  }

  bool hasMorePosts(int categoryId) {
    return _hasMorePostsByCategory[categoryId] ?? true;
  }

  List<dynamic> get searchResults => _searchResults;
  bool get searchLoading => _searchLoading;

  // Load cached posts from Hive
  void _loadCachedPosts() {
    // We are moving away from loading a large cache at startup to prevent memory issues.
    // This function can be left empty or used for other initialization if needed.
    print('PostsProvider initialized. Caching is now handled on a per-category basis.');
  }

  // Save posts to Hive
  void _savePostsForCategory(int categoryId) {
    try {
      if (_postsByCategory.containsKey(categoryId)) {
        postsBox.put('category_$categoryId', _postsByCategory[categoryId]);
      }
    } catch (e) {
      print('Error saving posts for category $categoryId: $e');
    }
  }

  // Cache Management
  void _limitCacheSize() {
    if (_postsByCategory.length > _cacheLimit) {
      int categoryIdToRemove = _postsByCategory.keys.first;
      _postsByCategory.remove(categoryIdToRemove);
      _cacheTimestamps.remove(categoryIdToRemove);
      print('🗑️ Evicted category $categoryIdToRemove from cache.');
    }
  }

  bool _isCacheValid(int categoryId) {
    if (!_cacheTimestamps.containsKey(categoryId)) return false;
    DateTime? timestamp = _cacheTimestamps[categoryId];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) <= _cacheTTL;
  }

  // Fetch posts for a category
  Future<void> fetchPostsByCategory(int categoryId, {bool forceRefresh = false, bool isFetchingMore = false}) async {
    print(
      '🔵 fetchPostsByCategory called for categoryId: $categoryId, forceRefresh: $forceRefresh, isFetchingMore: $isFetchingMore',
    );

    if (_loadingByCategory[categoryId] == true) {
      debugPrint('🟡 Already loading category $categoryId, returning.');
      return;
    }

    // Load from cache first if it's the initial load for this session
    if (!isFetchingMore && !forceRefresh && _postsByCategory[categoryId] == null) {
      final cachedPosts = postsBox.get('category_$categoryId');
      if (cachedPosts != null && cachedPosts is List) {
        _postsByCategory[categoryId] = List<dynamic>.from(cachedPosts);
        _cacheTimestamps[categoryId] = DateTime.now();
        _currentPageByCategory[categoryId] = (_postsByCategory[categoryId]!.length / 10).ceil() + 1;
        debugPrint('✅ Posts loaded from cache for category $categoryId, count: ${cachedPosts.length}');
        notifyListeners();
        return;
      }
    }

    if (!_isCacheValid(categoryId) || forceRefresh) {
      debugPrint('Expired cache or forceRefresh, clearing posts for category $categoryId');
      _postsByCategory.remove(categoryId);
      _cacheTimestamps.remove(categoryId);
      _currentPageByCategory[categoryId] = 1;
      _hasMorePostsByCategory[categoryId] = true;
    } else if (!isFetchingMore &&
        _postsByCategory.containsKey(categoryId) &&
        _postsByCategory[categoryId]!.isNotEmpty) {
      debugPrint('✅ Posts already handled for category $categoryId, count: ${_postsByCategory[categoryId]!.length}');
      return;
    }

    _loadingByCategory[categoryId] = true;
    notifyListeners();

    try {
      int page = _currentPageByCategory.putIfAbsent(categoryId, () => 1);

      final url = 'https://jobsnoticebd.com/wp-json/wp/v2/posts?categories=$categoryId&page=$page&_embed';
      debugPrint('🌐 API Call: $url');

      final res = await http.get(Uri.parse(url));

      debugPrint('📡 Response Status: ${res.statusCode}');
      debugPrint('📦 Response Body Length: ${res.body.length}');

      if (res.statusCode != 200) {
        debugPrint('❌ API Error: Status ${res.statusCode}');
        _hasMorePostsByCategory[categoryId] = false;
        return;
      }

      final posts = jsonDecode(res.body);

      debugPrint('📊 Posts received: ${posts is List ? posts.length : 'Not a list'}');

      if (posts is! List<dynamic> || posts.isEmpty) {
        debugPrint('⚠️ No more posts found for page $page');
        _hasMorePostsByCategory[categoryId] = false;
        return;
      }

      // Process posts to extract featured image
      for (var post in posts) {
        String imageUrl =
            'https://jobsnoticebd.com/wp-content/uploads/2024/09/Screenshot_20240905-111559_Facebook-1-300x200.jpg';

        // Try to get image from _embedded
        if (post['_embedded'] != null &&
            post['_embedded']['wp:featuredmedia'] != null &&
            post['_embedded']['wp:featuredmedia'].isNotEmpty) {
          var media = post['_embedded']['wp:featuredmedia'][0];
          if (media['source_url'] != null) {
            imageUrl = media['source_url'];
          }
        } // Fallback to jetpack_featured_media_url if available
        else if (post['jetpack_featured_media_url'] != null &&
            post['jetpack_featured_media_url'].toString().isNotEmpty) {
          imageUrl = post['jetpack_featured_media_url'];
        }

        // Add image URL to post data
        post['featured_image_url'] = imageUrl;
      }

      _postsByCategory[categoryId] = List<dynamic>.from(posts);
      _cacheTimestamps[categoryId] = DateTime.now();
      _currentPageByCategory[categoryId] = page + 1;

      _savePostsForCategory(categoryId);
      _limitCacheSize();
    } catch (e) {
      print('❌ Error fetching posts: $e');
      _hasMorePostsByCategory[categoryId] = false;
    } finally {
      _loadingByCategory[categoryId] = false;
      notifyListeners();
      print('🏁 Finished loading category $categoryId. Loading: false');
    }
  }

  Future<void> fetchMorePosts(int categoryId) async {
    if (_loadingByCategory[categoryId] == true || _hasMorePostsByCategory[categoryId] == false) return;

    await fetchPostsByCategory(categoryId, isFetchingMore: true);
  }

  // Search posts
  Future<void> searchPosts(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _searchLoading = true;
    _searchResults = [];
    notifyListeners();

    try {
      for (int i = 1; i <= 10; i++) {
        final res = await http.get(Uri.parse('https://jobsnoticebd.com/wp-json/wp/v2/search?search=$query&page=$i'));

        if (res.statusCode != 200) break;

        final searchData = jsonDecode(res.body);

        if (searchData is! List<dynamic> || searchData.isEmpty) break;

        for (var item in searchData) {
          try {
            final postRes = await http.get(
              Uri.parse('https://jobsnoticebd.com/wp-json/wp/v2/posts/${item['id']}?_embed'),
            );

            if (postRes.statusCode == 200) {
              final post = jsonDecode(postRes.body);

              // Extract image URL
              String imageUrl = '';
              if (post['_embedded'] != null &&
                  post['_embedded']['wp:featuredmedia'] != null &&
                  post['_embedded']['wp:featuredmedia'].isNotEmpty) {
                var media = post['_embedded']['wp:featuredmedia'][0];
                if (media['source_url'] != null) {
                  imageUrl = media['source_url'];
                }
              } else if (post['jetpack_featured_media_url'] != null) {
                imageUrl = post['jetpack_featured_media_url'];
              }

              _searchResults.add({'id': post['id'], 'title': post['title']['rendered'], 'image': imageUrl});

              notifyListeners();
            }
          } catch (e) {
            debugPrint('Error fetching search result: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error in search: $e');
    } finally {
      _searchLoading = false;
      notifyListeners();
    }
  }

  // Clear search results
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  // Refresh posts for a category
  Future<void> refreshCategory(int categoryId) async {
    await fetchPostsByCategory(categoryId, forceRefresh: true);
  }
}
