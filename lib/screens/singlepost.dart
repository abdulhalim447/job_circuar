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
  final dynamic acf;

  const SinglePostPage({
    super.key,
    required this.title,
    required this.image,
    required this.content,
    required this.date,
    required this.category,
    this.acf,
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
    h4 { font-size: 19px !important; }
    h5 { font-size: 18px !important; }
    h6 { font-size: 16px !important; }
    /* All gb-headline headings are center-aligned on the website */
    /* Confirmed by SEO analysis: h2(15), h3(5), h5(8), h6(3) all use gb-headline-text */
    .gb-headline-text {
      text-align: center !important;
      display: block !important;
      width: 100% !important;
    }
    h3.wp-block-heading, h5.wp-block-heading {
      text-align: center !important;
    }
    /* Fix figure > a > img so images inside anchor tags show properly */
    /* SEO data shows 20 images, all lazy-loaded - handled in Dart code */
    figure a img, figure img {
      width: 100% !important;
      height: auto !important;
      border-radius: 10px;
      box-shadow: rgba(0,0,0,0.20) 0px 5px 10px;
      margin: 10px 0;
      display: block !important;
    }
    figure a {
      display: block !important;
      width: 100% !important;
    }
    /* wp-block-latest-posts: related post grid */
    .wp-block-latest-posts {
      padding-left: 0 !important;
      list-style: none !important;
    }
    .wp-block-latest-posts li {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 8px 0;
      border-bottom: 1px solid $borderColor;
    }
    .wp-block-latest-posts__featured-image img {
      width: 80px !important;
      height: 50px !important;
      object-fit: cover;
      border-radius: 6px;
      box-shadow: none !important;
      margin: 0 !important;
    }
    .wp-block-latest-posts__post-title {
      font-size: 14px;
      line-height: 1.4;
      color: $linkColor !important;
    }
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
      font-family: 'Noto Sans Bengali', 'SolaimanLipi', Arial, sans-serif !important;
      text-align: center !important;
      transition: all 0.3s ease !important;
      box-sizing: border-box !important;
      border: none !important;
    }
    /* Force inner elements like <mark> to inherit color and font */
    .wp-block-button__link *, a.button * {
      color: #ffffff !important;
      font-family: inherit !important;
      background-color: transparent !important;
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
    .acf-box {
      border-left: 4px solid red;
      border-right: 4px solid red;
      background-color: $articleBgColor;
      border-radius: 12px;
      padding: 15px;
      margin: 20px 0;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    }
    .acf-item {
      display: flex;
      align-items: flex-start;
      margin-bottom: 12px;
      font-size: 16px;
    }
    .acf-icon {
      margin-right: 10px;
      font-size: 18px;
      opacity: 0.7;
    }
    .acf-label {
      font-weight: 600;
      color: $headingColor;
    }
    .acf-value-red {
      color: red;
      font-weight: bold;
    }
    .acf-value-green {
      color: green;
      font-weight: bold;
    }
    .acf-value-black {
      color: $textColor;
    }
    .kksr-stars, .kksr-stars-inactive, .kksr-stars-active {
      display: flex !important;
      flex-direction: row !important;
      align-items: center;
    }
    .kksr-star {
      display: inline-block !important;
    }
    .kk-star-ratings {
      margin: 0 !important;
      padding: 0 !important;
    }
    p:empty {
      display: none !important;
    }
    </style>
    ''';

    String cleanContent = widget.content;

    String acfHtml = '';
    if (widget.acf != null && widget.acf is Map) {
      final runningCircular = widget.acf['running_circular']?.toString() ?? '';
      final jobPostCategory = widget.acf['job_post_category']?.toString() ?? '';
      final vacancies = widget.acf['vacancies']?.toString() ?? '';
      final deadlineRaw = widget.acf['deadline']?.toString() ?? '';

      // Parse each deadline date and compute days remaining
      String deadlineHtml = '';
      if (deadlineRaw.isNotEmpty) {
        // Split by ',' or ',' (Bengali comma) or ' ও '
        final parts = deadlineRaw.split(RegExp(r'[,،]|\sও\s'));
        final today = DateTime.now();
        final Map<String, int> bengaliMonths = {
          'জানুয়ারি': 1, 'ফেব্রুয়ারি': 2, 'মার্চ': 3, 'এপ্রিল': 4,
          'মে': 5, 'জুন': 6, 'জুলাই': 7, 'আগস্ট': 8,
          'সেপ্টেম্বর': 9, 'অক্টোবর': 10, 'নভেম্বর': 11, 'ডিসেম্বর': 12,
        };
        // Bengali digits to ASCII
        String toAscii(String s) {
          const bengali = '০১২৩৪৫৬৭৮৯';
          var res = '';
          for (var c in s.split('')) {
            final idx = bengali.indexOf(c);
            res += idx >= 0 ? idx.toString() : c;
          }
          return res;
        }

        // Try to find the last year mentioned in the full deadline string
        int? globalYear;
        final yearMatch = RegExp(r'[০-৯]{4}').firstMatch(deadlineRaw);
        if (yearMatch != null) {
          globalYear = int.tryParse(toAscii(yearMatch.group(0)!));
        }

        // Collect parsed dates with day count
        final List<Map<String, dynamic>> deadlineDates = [];
        for (final part in parts) {
          final trimmed = part.trim();
          if (trimmed.isEmpty) continue;
          // Match pattern: "DD মাস YYYY" or "DD মাস"
          final match = RegExp(
            r'([০-৯]{1,2})\s+([\u0980-\u09FF]+)(?:\s+([০-৯]{4}))?'
          ).firstMatch(trimmed);
          if (match != null) {
            final dayStr = toAscii(match.group(1)!);
            final monthName = match.group(2)!;
            final yearStr = match.group(3) != null ? toAscii(match.group(3)!) : null;
            final day = int.tryParse(dayStr);
            final month = bengaliMonths[monthName];
            final year = yearStr != null ? int.tryParse(yearStr) : globalYear;
            if (day != null && month != null && year != null) {
              final deadline = DateTime(year, month, day);
              final diff = deadline.difference(DateTime(today.year, today.month, today.day)).inDays;
              deadlineDates.add({'label': trimmed, 'diff': diff, 'date': deadline});
            } else {
              deadlineDates.add({'label': trimmed, 'diff': null, 'date': null});
            }
          } else {
            deadlineDates.add({'label': trimmed, 'diff': null, 'date': null});
          }
        }

        if (deadlineDates.isNotEmpty) {
          // Find nearest upcoming deadline
          final upcoming = deadlineDates.where((d) => d['diff'] != null && d['diff'] >= 0).toList()
            ..sort((a, b) => (a['diff'] as int).compareTo(b['diff'] as int));
          final nearest = upcoming.isNotEmpty ? upcoming.first : null;

          // Build deadline rows
          final rows = deadlineDates.map((d) {
            final diff = d['diff'] as int?;
            String badge = '';
            if (diff == null) {
              badge = '';
            } else if (diff < 0) {
              badge = '<span style="color:#888;font-size:13px;"> → শেষ হয়েছে</span>';
            } else if (diff == 0) {
              badge = '<span style="color:red;font-weight:bold;font-size:13px;"> → আজই শেষ!</span>';
            } else {
              badge = '<span style="color:red;font-size:13px;"> → ${diff} দিন বাকি</span>';
            }
            return '<div style="margin:4px 0;">${d['label']}$badge</div>';
          }).join('');

          String nearestBanner = '';
          if (nearest != null) {
            nearestBanner = '<div style="background:#fff3f3;border:1px solid #ffaaaa;border-radius:8px;padding:8px 12px;margin-bottom:8px;font-weight:bold;color:red;font-size:15px;">⏰ পরবর্তী আবেদনের শেষ তারিখ: ${nearest['label']} → ${nearest['diff']} দিন বাকি</div>';
          }

          deadlineHtml = '$nearestBanner$rows';
        } else {
          deadlineHtml = '<div>$deadlineRaw</div>';
        }
      }

      if (runningCircular.isNotEmpty || jobPostCategory.isNotEmpty || vacancies.isNotEmpty) {
        acfHtml = '''
        <div class="acf-box">
          <div class="acf-item">
            <span class="acf-icon">📄</span>
            <div><span class="acf-label">চলমান নিয়োগ:</span> <span class="acf-value-red">$runningCircular</span></div>
          </div>
          <div class="acf-item">
            <span class="acf-icon">📋</span>
            <div><span class="acf-label">পদ ক্যাটাগরি:</span> <span class="acf-value-black">$jobPostCategory</span></div>
          </div>
          <div class="acf-item">
            <span class="acf-icon">👤</span>
            <div><span class="acf-label">মোট পদের সং&zwnj;খ্যা:</span> <span class="acf-value-green">$vacancies</span></div>
          </div>
          ${deadlineRaw.isNotEmpty ? '''
          <div class="acf-item" style="flex-direction:column;align-items:flex-start;">
            <div style="display:flex;align-items:center;margin-bottom:8px;">
              <span class="acf-icon" style="margin-right:10px;">📅</span>
              <span class="acf-label">আবেদনের শেষ তারিখ:</span>
            </div>
            <div style="padding-left:28px;color:$textColor;">$deadlineHtml</div>
          </div>''' : ''}
        </div>
        ''';
      }
    }

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
          $acfHtml
          <div class="entry-content">
            $cleanContent
          </div>
        </div>
        ''';

    // Fix lazy-loaded images (SEO data: all 20 images are lazy-loaded)
    // WebView doesn't always trigger lazy loading, so force eager loading
    // Also remove srcset which can confuse the WebView renderer
    return content
        .replaceAll(r'\n', '')
        .replaceAll(r'target=\"_blank\"', '')
        .replaceAll(r'rel=\"noreferrer', '')
        .replaceAll(r'noopener\', '')
        .replaceAll('<p>&nbsp;</p>', '')
        .replaceAll('<p><br></p>', '')
        .replaceAll('loading="lazy"', 'loading="eager"')
        .replaceAll('loading=\'lazy\'', 'loading=\'eager\'')
        .replaceAll(RegExp(r'\ssrcset="[^"]*"'), '')
        .replaceAll(RegExp(r"\ssrcset='[^']*'"), '')
        .replaceAll(RegExp(r'\ssizes="[^"]*"'), '')
        .replaceAll(RegExp(r"\ssizes='[^']*'"), '')
        .replaceAll(RegExp(r'\sdecoding="[^"]*"'), '');
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
