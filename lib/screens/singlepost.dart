import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:job_circular/models/favouritepost.dart';
import 'package:job_circular/utis/models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/singlepost.dart';

class SinglePostPage extends StatefulWidget {
  final String title, image, content, date;
  final int category;

  const SinglePostPage({
    super.key,
    required this.title,
    required this.image,
    required this.content,
    required this.date,
    required this.category,
  });

  @override
  State<SinglePostPage> createState() => _SinglePostPageState();
}

class _SinglePostPageState extends State<SinglePostPage> {
  String title = '', image = '', content = '', style = '', fimage = '', date = '';
  late int category;
  late WebViewController controller;
  bool isfav = false;
  int index = -1;
  @override
  void initState() {
    super.initState();
    title = widget.title;
    image = widget.image;
    category = widget.category;
    date = widget.date;
    style = '''
    <style>
    img{
    width:100% !important;
    }
    *{
    font-size:45px !important;
    }
    td{
    border:1px solid black;
    }
    .wp-block-buttons a{
    text-decoration:none !important;
    color:white !important;
    padding:15px 25px !important;
    border-radius:8px !important;
    border:1px solid rgba(0,240,0,0.4) !important;
    background:rgba(0,240,0,0.4) !important;
    }
    </style>
    ''';
    fimage =
        '''
    <img style="width:100%;" src="$image">
    ''';

    content =
        style +
        fimage +
        '<div style="padding: 0 20px;">' +
        '''
        <div style="display:flex;justify-content:end;margin-top:20px;">Date: ${date}</div>
        ''' +
        widget.content +
        '</div>';
    content.replaceAll(r'\n', '');
    content.replaceAll(r'target=\"_blank\"', '');
    content.replaceAll(r'rel=\"noreferrer', '');
    content.replaceAll(r'noopener\', '');

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(content)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (u) async {
            await controller.goBack();
            if (u.url != 'about:blank') {
              showAdaptiveDialog(
                context: context,
                builder: (_) => AlertDialog(
                  content: Text('Dow you want to visit ${u.url}?'),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        if (await controller.canGoBack()) {
                          await controller.goBack();
                        }
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await launchUrl(Uri.parse(u.url!));
                        } catch (e) {}
                      },
                      child: Text('Visit'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      );

    for (int i = 0; i < favourites.length; i++) {
      var post = favourites.getAt(i)!.singlePosts;
      if (post.title == title) {
        isfav = true;
        index = i;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Add To Favourites',
            onPressed: () async {
              if (isfav) {
                setState(() {
                  favourites.deleteAt(index);
                  isfav = false;
                });
                await Fluttertoast.showToast(
                  msg: "Deleted From Favourites",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              } else {
                favourites.add(
                  FavouritePost(
                    singlePosts: SinglePost(title: title, img: image, content: content, category: category, date: date),
                  ),
                );
                setState(() {
                  isfav = true;
                  index = favourites.length - 1;
                });
                await Fluttertoast.showToast(
                  msg: "Added To Favourites",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            },
            icon: Icon(isfav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (await controller.canGoBack()) {
            await controller.goBack();
            return false;
          }
          return true;
        },
        child: WebViewWidget(controller: controller),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
