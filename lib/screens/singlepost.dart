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
  String title = '', image = '', date = '';
  late int category;
  late WebViewController controller;
  bool isfav = false;
  int index = -1;
  bool _controllerInitialized = false;

  @override
  void initState() {
    super.initState();
    title = widget.title;
    image = widget.image;
    category = widget.category;
    date = widget.date;

    // Initialize controller once
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load HTML content with current theme
    if (!_controllerInitialized) {
      final htmlContent = _generateHtmlContent(context);
      controller.loadHtmlString(htmlContent);
      _controllerInitialized = true;
    }
  }

  String _generateHtmlContent(BuildContext context) {
    // Detect if dark mode is enabled from app theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Dynamic colors based on theme
    final backgroundColor = isDarkMode ? '#1a1a1a' : '#ffffff';
    final textColor = isDarkMode ? '#e0e0e0' : '#333333';
    final headingColor = isDarkMode ? '#ffffff' : '#000000';
    final tableBorderColor = isDarkMode ? '#444444' : '#dddddd';
    final tableEvenRowBg = isDarkMode ? '#2a2a2a' : '#f2f2f2';
    final linkColor = isDarkMode ? '#64b5f6' : '#007bff';

    final style =
        '''
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
    * {
      box-sizing: border-box;
    }
    img {
      max-width: 100% !important;
      width: 100% !important;
      height: auto !important;
      display: block;
      margin: 0 !important;
      padding: 0 !important;
      object-fit: contain;
    }
    figure, .wp-block-image, .wp-block-media-text {
      max-width: 100% !important;
      width: 100% !important;
      margin: 0 !important;
      padding: 0 !important;
    }
    figure img, .wp-block-image img {
      max-width: 100% !important;
      width: 100% !important;
      height: auto !important;
      margin: 0 !important;
      padding: 0 !important;
    }
    p img, div img, span img {
      max-width: 100% !important;
      width: 100% !important;
      height: auto !important;
      margin: 0 !important;
      padding: 0 !important;
    }
    body {
      font-size: 16px !important;
      line-height: 1.6;
      font-family: 'Roboto', sans-serif;
      margin: 0 !important;
      padding: 0 !important;
      background-color: $backgroundColor !important;
      color: $textColor !important;
      word-wrap: break-word;
      overflow-x: hidden;
    }
    h1, h2, h3, h4, h5, h6 {
      font-size: 1.3em !important;
      font-weight: bold;
      margin-top: 10px;
      margin-bottom: 5px;
      padding: 0 10px;
      color: $headingColor !important;
    }
    p {
      font-size: 16px !important;
      margin: 5px 0;
      padding: 0 10px;
      max-width: 100%;
      overflow-x: auto;
      color: $textColor !important;
    }
    div {
      color: $textColor !important;
    }
    table {
      width: 100% !important;
      border-collapse: collapse;
      margin: 10px 0;
      display: block;
      overflow-x: auto;
      background-color: $backgroundColor !important;
    }
    td, th {
      border: 1px solid $tableBorderColor !important;
      padding: 8px;
      text-align: left;
      color: $textColor !important;
      background-color: transparent !important;
    }
    tr:nth-child(even) {
      background-color: $tableEvenRowBg !important;
    }
    tr:nth-child(even) td {
      background-color: $tableEvenRowBg !important;
    }
    a {
      color: $linkColor !important;
      text-decoration: none;
    }
    ul, ol {
      padding-left: 20px;
      margin: 5px 0;
      color: $textColor !important;
    }
    li {
      color: $textColor !important;
    }
    .wp-block-buttons a{
      text-decoration:none !important;
      color:white !important;
      padding:15px 25px !important;
      border-radius:8px !important;
      border:1px solid rgba(0,240,0,0.4) !important;
      background:rgba(0,240,0,0.4) !important;
    }
    strong, b {
      color: $headingColor !important;
    }
    </style>
    ''';

    final fimage =
        '''
    <img style="width:100%;" src="$image">
    ''';

    final content =
        style +
        fimage +
        '<div style="padding: 0 20px;">' +
        '''
        <div style="display:flex;justify-content:end;margin-top:20px;color:$textColor;">Date: ${date}</div>
        ''' +
        widget.content +
        '</div>';

    return content
        .replaceAll(r'\n', '')
        .replaceAll(r'target=\"_blank\"', '')
        .replaceAll(r'rel=\"noreferrer', '')
        .replaceAll(r'noopener\', '');
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
                    singlePosts: SinglePost(
                      title: title,
                      img: image,
                      content: widget.content,
                      category: category,
                      date: date,
                    ),
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
            icon: Icon(
              isfav ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
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
