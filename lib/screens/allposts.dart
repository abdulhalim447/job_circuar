import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:job_circular/screens/singlepost.dart';
import 'package:provider/provider.dart';

import '../providers/posts_provider.dart';
import '../utis/methods.dart';

class AllPosts extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  const AllPosts({super.key, required this.categoryId, required this.categoryName});

  @override
  State<AllPosts> createState() => _AllPostsState();
}

class _AllPostsState extends State<AllPosts> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch posts when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostsProvider>(context, listen: false).fetchPostsByCategory(widget.categoryId);
    });

    _scrollController.addListener(() {
      // Load more posts when scrolled 50% down
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.5) {
        Provider.of<PostsProvider>(context, listen: false).fetchMorePosts(widget.categoryId);
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
        final posts = postsProvider.getPostsByCategory(widget.categoryId);
        final loading = postsProvider.isLoadingCategory(widget.categoryId);

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Text(widget.categoryName),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  postsProvider.refreshCategory(widget.categoryId);
                },
              ),
            ],
          ),
          body: (loading && posts.isEmpty)
              ? Center(child: CircularProgressIndicator())
              : posts.isEmpty
              ? Center(
                  child: Text('No Posts To Display', style: TextStyle(fontSize: 20, color: Colors.red)),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await postsProvider.refreshCategory(widget.categoryId);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: GridView.builder(
                      controller: _scrollController,
                      itemCount: posts.length + (postsProvider.hasMorePosts(widget.categoryId) ? 1 : 0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                      itemBuilder: (_, i) {
                        if (i == posts.length) {
                          return Center(child: CircularProgressIndicator());
                        }
                        var post = posts[i];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SinglePostPage(
                                  title: post['title']['rendered'] ?? 'No Title',
                                  date: getDate(post['date'] ?? ''),
                                  image:
                                      post['featured_image_url'] ??
                                      'https://jobsnoticebd.com/wp-content/uploads/2024/09/Screenshot_20240905-111559_Facebook-1-300x200.jpg',
                                  content: post['content']['rendered'] ?? '',
                                  category: widget.categoryId,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Color(0xfffefefe),
                            child: Center(
                              child: Column(
                                children: [
                                  Flexible(
                                    child: CachedNetworkImage(
                                      width: double.infinity,
                                      fit: BoxFit.fill,
                                      fadeInDuration: Duration.zero,
                                      fadeOutDuration: Duration.zero,
                                      imageUrl:
                                          post['featured_image_url'] ??
                                          'https://jobsnoticebd.com/wp-content/uploads/2024/09/Screenshot_20240905-111559_Facebook-1-300x200.jpg',
                                      placeholder: (context, url) => Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[300],
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.image_not_supported, size: 50, color: Colors.grey[600]),
                                            SizedBox(height: 5),
                                            Text(
                                              'Image not available',
                                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Expanded(child: Text(post['title']['rendered'], textAlign: TextAlign.center)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('Publish Date: ${getDate(post['date'])}', style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        );
      },
    );
  }
}
