import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../services/api_service.dart';

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
    else if (post['jetpack_featured_media_url'] != null &&
        post['jetpack_featured_media_url'].toString().isNotEmpty) {
      imageUrl = post['jetpack_featured_media_url'];
    }

    // Add image URL to post data
    post['featured_image_url'] = imageUrl;
  }

  return posts;
}

class PostsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService.instance;

  // Posts by category
  LinkedHashMap<int, List<dynamic>> _postsByCategory = LinkedHashMap();
  Map<int, bool> _loadingByCategory = {};
  Map<int, int> _currentPageByCategory = {};
  Map<int, bool> _hasMorePostsByCategory = {};
  Map<int, bool> _isRefreshingByCategory = {}; // Track background refresh

  // Search results
  List<dynamic> _searchResults = [];
  bool _searchLoading = false;
  bool _disposed = false;
  Timer? _searchDebounce;

  PostsProvider() {
    // Initialize API service
    _apiService.initialize();
  }

  @override
  void dispose() {
    _disposed = true;
    _searchDebounce?.cancel();
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

  bool isRefreshingCategory(int categoryId) {
    return _isRefreshingByCategory[categoryId] ?? false;
  }

  bool hasMorePosts(int categoryId) {
    return _hasMorePostsByCategory[categoryId] ?? true;
  }

  List<dynamic> get searchResults => _searchResults;
  bool get searchLoading => _searchLoading;

  /// Fetch posts for a category with stale-while-revalidate strategy
  Future<void> fetchPostsByCategory(
    int categoryId, {
    bool isFetchingMore = false,
    bool forceRefresh = false,
  }) async {
    debugPrint(
      '🔵 fetchPostsByCategory: categoryId=$categoryId, isFetchingMore=$isFetchingMore, forceRefresh=$forceRefresh',
    );

    if (_loadingByCategory[categoryId] == true && !forceRefresh) {
      debugPrint('🟡 Already loading category $categoryId');
      return;
    }

    if (!isFetchingMore && !forceRefresh) {
      _currentPageByCategory[categoryId] = 1;
      _hasMorePostsByCategory[categoryId] = true;
    }

    _loadingByCategory[categoryId] = true;
    if (forceRefresh) {
      _isRefreshingByCategory[categoryId] = true;
    }
    notifyListeners();

    try {
      if (_disposed) return;
      int page = _currentPageByCategory.putIfAbsent(categoryId, () => 1);

      debugPrint('🌐 API Call: category=$categoryId, page=$page');

      // Fetch with caching (stale-while-revalidate)
      final response = await _apiService.fetchPosts(
        categoryId: categoryId == 0 ? null : categoryId,
        page: page,
        perPage: 10,
        forceRefresh: forceRefresh,
      );

      if (_disposed) return;

      debugPrint('📡 Response Status: ${response.statusCode}');

      // Check if data came from cache
      final cacheResponse = response.extra['cache_response'];
      if (cacheResponse != null) {
        debugPrint('⚡ Data from CACHE (${cacheResponse.runtimeType})');
      }

      if (response.statusCode != 200) {
        debugPrint('❌ API Error: Status ${response.statusCode}');
        _hasMorePostsByCategory[categoryId] = false;
        return;
      }

      // Parse JSON in isolate
      final posts = await compute(_parsePosts, jsonEncode(response.data));

      if (_disposed) return;

      debugPrint('📊 Posts received: ${posts.length}');

      if (posts.isEmpty) {
        debugPrint('⚠️ No more posts for page $page');
        _hasMorePostsByCategory[categoryId] = false;
        return;
      }

      if (isFetchingMore) {
        _postsByCategory[categoryId]!.addAll(posts);
      } else {
        _postsByCategory[categoryId] = List<dynamic>.from(posts);
      }

      _currentPageByCategory[categoryId] = page + 1;
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.type} - ${e.message}');
      _hasMorePostsByCategory[categoryId] = false;
    } catch (e) {
      debugPrint('❌ Error fetching posts: $e');
      _hasMorePostsByCategory[categoryId] = false;
    } finally {
      _loadingByCategory[categoryId] = false;
      _isRefreshingByCategory[categoryId] = false;
      notifyListeners();
      debugPrint('🏁 Finished loading category $categoryId');

      // Auto-fetch next batch on initial load
      if (!isFetchingMore &&
          !forceRefresh &&
          _hasMorePostsByCategory[categoryId] == true) {
        debugPrint('🚀 Auto-fetching next batch');
        fetchMorePosts(categoryId);
      }
    }
  }

  Future<void> fetchMorePosts(int categoryId) async {
    if (_loadingByCategory[categoryId] == true ||
        _hasMorePostsByCategory[categoryId] == false)
      return;
    await fetchPostsByCategory(categoryId, isFetchingMore: true);
  }

  /// Search posts with debouncing
  Future<void> searchPosts(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    // Cancel previous debounce timer
    _searchDebounce?.cancel();

    // Debounce search by 300ms
    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      await _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    _searchLoading = true;
    _searchResults = [];
    notifyListeners();

    try {
      // Search with caching
      final searchResponse = await _apiService.searchPosts(query, page: 1);

      if (searchResponse.statusCode != 200) {
        debugPrint('❌ Search API Error: ${searchResponse.statusCode}');
        return;
      }

      final searchData = searchResponse.data as List<dynamic>;

      if (searchData.isEmpty) {
        debugPrint('⚠️ No search results');
        return;
      }

      // Fetch full post details for each result
      for (var item in searchData.take(20)) {
        // Limit to 20 results
        try {
          final postResponse = await _apiService.getPost(item['id']);

          if (postResponse.statusCode == 200) {
            final post = postResponse.data;

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

            _searchResults.add({
              'id': post['id'],
              'title': post['title']['rendered'],
              'image': imageUrl,
            });

            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error fetching search result: $e');
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
    _searchDebounce?.cancel();
    notifyListeners();
  }

  // Refresh posts for a category (force refresh from server)
  Future<void> refreshCategory(int categoryId) async {
    await fetchPostsByCategory(categoryId, forceRefresh: true);
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    await _apiService.clearCache();
    _postsByCategory.clear();
    _searchResults.clear();
    notifyListeners();
  }
}
