import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:job_circular/models/favouritepost.dart';
import 'package:job_circular/utis/models.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/singlepost.dart';
import 'in_app_webview_screen.dart';

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
          onNavigationRequest: (NavigationRequest request) async {
            // Allow about:blank and data URLs
            if (request.url.startsWith('about:blank') ||
                request.url.startsWith('data:')) {
              return NavigationDecision.navigate;
            }

            // Direct redirection to InAppWebViewScreen for external links
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InAppWebViewScreen(url: request.url),
              ),
            );

            return NavigationDecision.prevent;
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
    final backgroundColor = isDarkMode ? '#1a1a1a' : '#f7f8f9';
    final articleBgColor = isDarkMode ? '#242424' : '#ffffff';
    final borderColor = isDarkMode ? '#333333' : '#e0e0e0';
    final textColor = isDarkMode ? '#e0e0e0' : '#333333';
    final headingColor = isDarkMode ? '#ffffff' : '#000000';
    final tableBorderColor = isDarkMode ? '#444444' : '#dddddd';
    final tableEvenRowBg = isDarkMode ? '#2a2a2a' : '#f2f2f2';
    final linkColor = isDarkMode ? '#1b78e2' : '#1b78e2';
    final metaColor = isDarkMode ? '#aaaaaa' : '#757575';

    final style =
        '''
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Bengali:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
    * {
      box-sizing: border-box;
    }
    body {
      font-size: 17px !important;
      line-height: 1.6;
      font-family: 'Noto Sans Bengali', 'SolaimanLipi', Arial, sans-serif !important;
      margin: 0 !important;
      padding: 10px 10px !important;
      background-color: $backgroundColor !important;
      color: $textColor !important;
      word-wrap: break-word;
      overflow-x: hidden;
    }
    .inside-article {
      background-color: $articleBgColor;
      border: 1px solid $borderColor;
      border-radius: 12px;
      padding: 15px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.02);
      margin-bottom: 20px;
    }
    h1.entry-title {
      font-size: 24px !important;
      font-weight: 700;
      margin-top: 0;
      margin-bottom: 15px;
      color: $headingColor !important;
      line-height: 1.4;
    }
    .entry-meta {
      display: flex;
      align-items: center;
      margin-bottom: 20px;
      color: $metaColor;
      font-size: 15px;
      flex-wrap: wrap;
    }
    .byline {
      font-weight: 700;
      color: $headingColor;
      display: flex;
      align-items: center;
    }
    .byline::after {
      content: "";
      display: inline-block;
      width: 16px;
      height: 16px;
      margin-left: 5px;
      vertical-align: middle;
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath fill='%231DA1F2' d='M23 12l-2.44-2.78.34-3.68-3.61-.82L15.4 1.54 12 3 8.6 1.54 6.71 4.72 3.1 5.53l.34 3.68L1 12l2.44 2.78-.34 3.69 3.61.82L8.6 22.47 12 21l3.4 1.46 1.89-3.18 3.61-.82-.34-3.68L23 12zM10 17l-4-4 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z'/%3E%3C/svg%3E");
      background-size: contain;
      background-repeat: no-repeat;
    }
    .posted-on {
      margin-left: 10px;
    }
    .posted-on::before {
      content: "•";
      margin-right: 10px;
    }
    .wp-block-image img {
      width: 100% !important;
      height: auto !important;
      border-radius: 10px;
      box-shadow: rgba(0, 0, 0, 0.20) 0px 5px 10px;
      margin: 20px 0;
    }
    .featured-image {
      width: 100% !important;
      height: auto !important;
      border-radius: 10px;
      box-shadow: rgba(0, 0, 0, 0.20) 0px 5px 10px;
      margin-bottom: 20px;
      display: block;
    }
    img {
      max-width: 100% !important;
      height: auto !important;
    }
    figure {
      margin: 15px 0 !important;
      max-width: 100% !important;
    }
    h1, h2, h3, h4, h5, h6 {
      font-weight: 700;
      margin-top: 25px;
      margin-bottom: 15px;
      color: $headingColor !important;
      line-height: 1.4;
    }
    h2 { font-size: 22px !important; }
    h3 { font-size: 20px !important; }
    p {
      font-size: 17px !important;
      margin: 15px 0;
      color: $textColor !important;
    }
    table {
      width: 100% !important;
      border-collapse: collapse;
      margin: 15px 0;
      display: block;
      overflow-x: auto;
    }
    td, th {
      border: 1px solid $tableBorderColor !important;
      padding: 10px;
      text-align: left;
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
      margin: 15px 0;
    }
    li {
      margin-bottom: 8px;
    }
    /* Button blocks */
    .wp-block-buttons {
      display: flex !important;
      flex-direction: column;
      gap: 10px;
      margin: 20px 0 !important;
    }
    .wp-block-button {
      width: 100% !important;
    }
    .wp-block-button__link, a.button {
      display: block !important;
      width: 100% !important;
      text-decoration: none !important;
      color: #ffffff !important;
      padding: 12px 20px !important;
      border-radius: 8px !important;
      background: #0A5E0E !important;
      font-weight: 600 !important;
      font-size: 16px !important;
      text-align: center !important;
      transition: all 0.3s ease !important;
      box-sizing: border-box !important;
      border: none !important;
    }
    .hot-jobs-label, .vacancies-label, .deadline-label {
      padding: 7px 10px;
      font-size: 13px;
      border-radius: 5px;
      font-weight: bold;
      margin-right: 5px;
      display: inline-block;
      margin-bottom: 10px;
      color: #fff;
    }
    .hot-jobs-label { background: red; box-shadow: 1px 3px 5px rgba(0, 0, 0, 0.3); }
    .vacancies-label { background: green; }
    .deadline-label { background: #fde5e5; color: red; }
    .gb-container, .gb-grid-wrapper, .gb-grid-column {
      max-width: 100% !important;
    }
    </style>
    ''';

    String cleanContent = widget.content;

    final content =
        style +
        '''
        <div class="inside-article">
          <h1 class="entry-title">${title}</h1>
          <div class="entry-meta">
            <span class="byline">Jobs Notice BD</span>
            <span class="posted-on">${date}</span>
          </div>
          <img class="featured-image" src="$image">
          <div class="entry-content">
            $cleanContent
          </div>
        </div>
        ''';

    return content
        .replaceAll(r'\n', '')
        .replaceAll(r'target=\"_blank\"', '')
        .replaceAll(r'rel=\"noreferrer', '')
        .replaceAll(r'noopener\', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: WebViewWidget(controller: controller),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
