import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/posts_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late FocusNode _focusNode;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    controller = TextEditingController();
  }

  void performSearch(PostsProvider provider) {
    if (controller.text.trim().isNotEmpty) {
      provider.searchPosts(controller.text.trim());
    } else {
      provider.clearSearch();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostsProvider>(
      builder: (context, postsProvider, child) {
        final searchResults = postsProvider.searchResults;
        final isLoading = postsProvider.searchLoading;

        return Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              TextFormField(
                onEditingComplete: () => performSearch(postsProvider),
                onChanged: (v) {
                  performSearch(postsProvider);
                },
                focusNode: _focusNode,
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            controller.clear();
                            postsProvider.clearSearch();
                          },
                        )
                      : null,
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : searchResults.isEmpty
                    ? Center(
                        child: Text(
                          controller.text.isEmpty ? 'Type to search' : 'No results found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        itemCount: searchResults.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                        itemBuilder: (_, i) {
                          var post = searchResults[i];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to post detail if needed
                            },
                            child: Card(
                              child: Center(
                                child: Column(
                                  children: [
                                    Flexible(
                                      child: CachedNetworkImage(
                                        imageUrl: (post['image'] != null && post['image'].toString().isNotEmpty)
                                            ? post['image']
                                            : 'https://jobsnoticebd.com/wp-content/uploads/2024/09/Screenshot_20240905-111559_Facebook-1-300x200.jpg',
                                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey[300],
                                          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[600]),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Expanded(child: Text(post['title'], textAlign: TextAlign.center)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
