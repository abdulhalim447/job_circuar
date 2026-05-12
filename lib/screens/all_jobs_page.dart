import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:job_circular/screens/singlepost.dart';
import 'package:provider/provider.dart';

import '../providers/posts_provider.dart';
import '../utis/methods.dart';
import 'main_drawer.dart';

class AllJobsPage extends StatefulWidget {
  const AllJobsPage({super.key});

  @override
  State<AllJobsPage> createState() => _AllJobsPageState();
}

class _AllJobsPageState extends State<AllJobsPage> {
  final ScrollController _scrollController = ScrollController();
  final int categoryId = 0;

  @override
  void initState() {
    super.initState();
    // Fetch posts when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostsProvider>(
        context,
        listen: false,
      ).fetchPostsByCategory(categoryId);
    });

    _scrollController.addListener(() {
      // Trigger fetch when user is 500 pixels from the bottom
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 500) {
        Provider.of<PostsProvider>(
          context,
          listen: false,
        ).fetchMorePosts(categoryId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostsProvider>(
      builder: (context, postsProvider, child) {
        final posts = postsProvider.getPostsByCategory(categoryId);
        final loading = postsProvider.isLoadingCategory(categoryId);

        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            titleSpacing: 0,
            title: const Text('All Jobs'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  postsProvider.refreshCategory(categoryId);
                },
              ),
            ],
          ),
          drawer: const MainDrawer(),
          body: (loading && posts.isEmpty)
              ? const Center(child: CircularProgressIndicator())
              : posts.isEmpty
              ? const Center(
                  child: Text(
                    'No Jobs To Display',
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await postsProvider.refreshCategory(categoryId);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                              ),
                          delegate: SliverChildBuilderDelegate((_, i) {
                            var post = posts[i];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SinglePostPage(
                                      title:
                                          post['title']['rendered'] ??
                                          'No Title',
                                      date: getDate(post['date'] ?? ''),
                                      image:
                                          post['featured_image_url'] ??
                                          'https://jobsnoticebd.com/wp-content/uploads/2024/09/Screenshot_20240905-111559_Facebook-1-300x200.jpg',
                                      content:
                                          post['content']['rendered'] ?? '',
                                      category: categoryId,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[700]!
                                        : Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Flexible(
                                        child: CachedNetworkImage(
                                          height: 200,
                                          fit: BoxFit.fill,
                                          fadeInDuration: Duration.zero,
                                          fadeOutDuration: Duration.zero,
                                          imageUrl:
                                              post['featured_image_url'] ??
                                              'https://jobsnoticebd.com/wp-content/uploads/2024/09/Screenshot_20240905-111559_Facebook-1-300x200.jpg',
                                          placeholder: (context, url) => Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                20.0,
                                              ),
                                              child:
                                                  const CircularProgressIndicator(),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                color: Colors.grey[300],
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.image_not_supported,
                                                      size: 50,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      'Image not available',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          post['title']['rendered'],
                                          textAlign: TextAlign.left,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xff046d22),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Publish Date: ${getDate(post['date'])}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }, childCount: posts.length),
                        ),
                        if (loading && posts.isNotEmpty)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
