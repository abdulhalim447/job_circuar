import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:job_circular/screens/singlepost.dart';
import 'package:provider/provider.dart';

import '../providers/favourites_provider.dart';

class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FavouritesProvider>(
      builder: (context, favouritesProvider, child) {
        final favourites = favouritesProvider.favourites;

        return Scaffold(
          appBar: AppBar(title: Text('Favourites'), titleSpacing: 0),
          body: favourites.isEmpty
              ? Container(
                  child: Center(
                    child: Text('No Posts To Display', style: TextStyle(fontSize: 20, color: Colors.green)),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: favourites.length,
                    itemBuilder: (_, i) {
                      var post = favourites[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SinglePostPage(
                                title: post.title,
                                image: post.img,
                                content: post.content,
                                category: post.category,
                                date: post.date,
                                acf: post.acf,
                              ),
                            ),
                          );
                        },
                        onLongPress: () {
                          showAdaptiveDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              content: ListTile(
                                title: Text('Delete'),
                                onTap: () {
                                  Navigator.pop(context);
                                  showAdaptiveDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text('Are you Sure?'),
                                      content: Text('Do you really want to delete this item?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            favouritesProvider.removeFavourite(post.title);
                                            Navigator.pop(context);
                                          },
                                          child: Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Theme.of(context).brightness == Brightness.dark
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
                                    imageUrl: (post.img != null && post.img.isNotEmpty)
                                        ? post.img
                                        : 'https://jobsnoticebd.com/wp-content/uploads/2024/09/Screenshot_20240905-111559_Facebook-1-300x200.jpg',
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
                                          Text('Image not available', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    post.title,
                                    textAlign: TextAlign.left,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(0xff046d22),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Publish Date: ${post.date ?? ""}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
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
        );
      },
    );
  }
}
