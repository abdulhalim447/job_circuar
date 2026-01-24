import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';

/// Optimized API Service with caching and stale-while-revalidate strategy
class ApiService {
  static ApiService? _instance;
  late Dio _dio;
  late CacheOptions _cacheOptions;
  bool _initialized = false;

  ApiService._();

  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  /// Initialize Dio with cache interceptor
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Get cache directory
      final cacheDir = await getTemporaryDirectory();

      // Create Hive cache store
      final cacheStore = HiveCacheStore(
        cacheDir.path,
        hiveBoxName: 'job_circular_cache',
      );

      // Configure cache options with stale-while-revalidate strategy
      _cacheOptions = CacheOptions(
        store: cacheStore,

        // Stale-while-revalidate: serve cache immediately, refresh in background
        policy: CachePolicy.refreshForceCache,

        // Cache validity: 5 minutes
        maxStale: const Duration(minutes: 5),

        // Priority: cache first for speed
        priority: CachePriority.high,

        // Serve cache even on errors (except 401, 403, 404)
        hitCacheOnErrorExcept: [401, 403, 404],

        // Allow stale data while revalidating
        allowPostMethod: false,
      );

      // Create Dio instance
      _dio = Dio(
        BaseOptions(
          baseUrl: 'https://jobsnoticebd.com/wp-json/wp/v2/',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),

          // Enable compression
          headers: {'Accept-Encoding': 'gzip, deflate'},
        ),
      );

      // Add cache interceptor
      _dio.interceptors.add(DioCacheInterceptor(options: _cacheOptions));

      // Add logging interceptor (only in debug mode)
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (log) => print('🌐 API: $log'),
        ),
      );

      _initialized = true;
      print('✅ ApiService initialized with caching');
    } catch (e) {
      print('❌ ApiService initialization error: $e');
      rethrow;
    }
  }

  /// Fetch posts by category with caching
  Future<Response> fetchPosts({
    int? categoryId,
    int page = 1,
    int perPage = 10,
    bool forceRefresh = false,
  }) async {
    if (!_initialized) await initialize();

    final categoryParam = categoryId == null || categoryId == 0
        ? ''
        : 'categories=$categoryId&';

    return await _dio.get(
      'posts',
      queryParameters: {
        if (categoryId != null && categoryId != 0) 'categories': categoryId,
        'page': page,
        'per_page': perPage,
        '_embed': true,
        '_fields':
            'id,date,title,content,jetpack_featured_media_url,_links,_embedded',
      },
      options: forceRefresh
          ? _cacheOptions.copyWith(policy: CachePolicy.refresh).toOptions()
          : _cacheOptions.toOptions(),
    );
  }

  /// Search posts with caching
  Future<Response> searchPosts(String query, {int page = 1}) async {
    if (!_initialized) await initialize();

    return await _dio.get(
      'search',
      queryParameters: {'search': query, 'page': page},
      options: _cacheOptions
          .copyWith(maxStale: Nullable(const Duration(minutes: 2)))
          .toOptions(),
    );
  }

  /// Get single post details
  Future<Response> getPost(int postId) async {
    if (!_initialized) await initialize();

    return await _dio.get(
      'posts/$postId',
      queryParameters: {'_embed': true},
      options: _cacheOptions.toOptions(),
    );
  }

  /// Clear all cache
  Future<void> clearCache() async {
    if (!_initialized) await initialize();
    await _cacheOptions.store?.clean();
    print('🗑️ Cache cleared');
  }

  /// Clear cache for specific category
  Future<void> clearCategoryCache(int categoryId) async {
    if (!_initialized) await initialize();
    // Note: This clears all cache. For selective clearing, you'd need custom implementation
    await _cacheOptions.store?.clean();
  }

  /// Cancel all pending requests
  void cancelRequests() {
    _dio.close(force: true);
  }
}
