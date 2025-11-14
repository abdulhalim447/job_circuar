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
              : ListView.separated(
                  itemCount: favourites.length,
                  itemBuilder: (_, i) {
                    var post = favourites[i];
                    return ListTile(
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
                      title: Text(post.title),
                      leading: CachedNetworkImage(
                        imageUrl: (post.img != null && post.img.isNotEmpty)
                            ? post.img
                            : 'https://jobsnoticebd.com/wp-content/uploads/2024/09/Screenshot_20240905-111559_Facebook-1-300x200.jpg',
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.image_not_supported),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                ),
        );
      },
    );
  }
}
