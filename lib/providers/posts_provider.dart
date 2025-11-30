import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Isolate function for parsing posts
List<dynamic> _parsePosts(String responseBody) {
  final posts = jsonDecode(responseBody);

  if (posts is! List<dynamic>) {
    return [];
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
    else if (post['jetpack_featured_media_url'] != null && post['jetpack_featured_media_url'].toString().isNotEmpty) {
      imageUrl = post['jetpack_featured_media_url'];
    }

    // Add image URL to post data
    post['featured_image_url'] = imageUrl;
  }

  return posts;
}

class PostsProvider extends ChangeNotifier {
  // Posts by category
  LinkedHashMap<int, List<dynamic>> _postsByCategory = LinkedHashMap();
  Map<int, bool> _loadingByCategory = {};
  Map<int, int> _currentPageByCategory = {};
  Map<int, bool> _hasMorePostsByCategory = {};

  // Search results
  List<dynamic> _searchResults = [];
  bool _searchLoading = false;
  bool _disposed = false;

  PostsProvider();

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
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

  // Fetch posts for a category
  Future<void> fetchPostsByCategory(int categoryId, {bool isFetchingMore = false}) async {
    print('🔵 fetchPostsByCategory called for categoryId: $categoryId, isFetchingMore: $isFetchingMore');

    if (_loadingByCategory[categoryId] == true) {
      debugPrint('🟡 Already loading category $categoryId, returning.');
      return;
    }

    if (!isFetchingMore) {
      debugPrint('Clearing posts for category $categoryId to fetch fresh data');
      _postsByCategory.remove(categoryId);
      _currentPageByCategory[categoryId] = 1;
      _hasMorePostsByCategory[categoryId] = true;
    }

    _loadingByCategory[categoryId] = true;
    notifyListeners();

    try {
      if (_disposed) return;
      int page = _currentPageByCategory.putIfAbsent(categoryId, () => 1);

      // Optimized API call with specific fields
      final url =
          'https://jobsnoticebd.com/wp-json/wp/v2/posts?categories=$categoryId&page=$page&per_page=10&_embed&_fields=id,date,title,content,jetpack_featured_media_url,_links,_embedded';
      debugPrint('🌐 API Call: $url');

      final res = await http.get(Uri.parse(url));

      debugPrint('📡 Response Status: ${res.statusCode}');
      debugPrint('📦 Response Body Length: ${res.body.length}');

      if (res.statusCode != 200) {
        debugPrint('❌ API Error: Status ${res.statusCode}');
        _hasMorePostsByCategory[categoryId] = false;
        return;
      }

      // Use compute to parse JSON in a separate isolate
      final posts = await compute(_parsePosts, res.body);

      if (_disposed) return;

      debugPrint('📊 Posts received: ${posts.length}');

      if (posts.isEmpty) {
        debugPrint('⚠️ No more posts found for page $page');
        _hasMorePostsByCategory[categoryId] = false;
        return;
      }

      if (isFetchingMore) {
        _postsByCategory[categoryId]!.addAll(posts);
      } else {
        _postsByCategory[categoryId] = List<dynamic>.from(posts);
      }

      _currentPageByCategory[categoryId] = page + 1;
    } catch (e) {
      print('❌ Error fetching posts: $e');
      _hasMorePostsByCategory[categoryId] = false;
    } finally {
      _loadingByCategory[categoryId] = false;
      notifyListeners();
      print('🏁 Finished loading category $categoryId. Loading: false');

      // Automatically fetch the next batch if this was the initial load
      if (!isFetchingMore && _hasMorePostsByCategory[categoryId] == true) {
        debugPrint('🚀 Auto-fetching next batch for category $categoryId');
        fetchMorePosts(categoryId);
      }
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
    await fetchPostsByCategory(categoryId);
  }
}
