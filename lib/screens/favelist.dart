import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:job_circular/screens/singlepost.dart';
import 'package:job_circular/utis/models.dart';

class FavListPage extends StatefulWidget {
  final bool isSettings;
  const FavListPage({super.key, required this.isSettings});

  @override
  State<FavListPage> createState() => _FavListPageState();
}

class _FavListPageState extends State<FavListPage> {
  late var fav;
  @override
  void initState() {
    super.initState();
    setState(() {
      fav = favourites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: !widget.isSettings,
      physics: widget.isSettings ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
      itemCount: fav.length,
      itemBuilder: (_, i) {
        var post = fav.getAt(i)!.singlePosts;
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
                              favourites.deleteAt(i);
                              setState(() {
                                fav = favourites;
                              });
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
          leading: CachedNetworkImage(imageUrl: post.img),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }
}
