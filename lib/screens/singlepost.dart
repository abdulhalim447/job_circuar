import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/singlepost.dart';
import 'in_app_webview_screen.dart';
import 'package:provider/provider.dart';
import '../providers/favourites_provider.dart';

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
      ..addJavaScriptChannel(
        'ImageSaver',
        onMessageReceived: (JavaScriptMessage message) {
          _showSaveImageDialog(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            // Allow about:blank and data URLs
            if (request.url.startsWith('about:blank') ||
                request.url.startsWith('data:')) {
              return NavigationDecision.navigate;
            }

            // Open in Chrome Custom Tabs for full browser experience
            // (downloads, PDF, image save, all link types supported)
            InAppBrowser.openUrl(context, request.url);

            return NavigationDecision.prevent;
          },
          onPageFinished: (String url) {
            _injectLongPressHandler();
          },
        ),
      );
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
      background: ${isDarkMode ? '#2a2a2a' : '#f9fbfc'};
      border-left: 4px solid red;
      border-right: 4px solid red;
      padding: 20px;
      margin-top: 15px;
      border-radius: 10px;
      margin-bottom: 25px;
      font-family: 'Noto Sans Bengali', 'Segoe UI', sans-serif;
      font-size: 14px;
      color: $textColor;
      box-shadow: 0 1px 5px rgba(0,0,0,0.05);
    }
    .acf-item {
      display: flex;
      align-items: center;
      margin-bottom: 12px;
      font-size: 14px;
    }
    .acf-item svg {
      flex-shrink: 0;
    }
    .acf-label {
      font-weight: bold;
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

      // SVG icons matching website exactly
      const svgDocument =
          '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle;margin-right:6px;flex-shrink:0;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>';
      const svgBook =
          '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle;margin-right:6px;flex-shrink:0;"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>';
      const svgUserPlus =
          '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle;margin-right:6px;flex-shrink:0;"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><path d="M20 8v6"></path><path d="M23 11h-6"></path></svg>';
      const svgCalendar =
          '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle;margin-right:6px;flex-shrink:0;"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>';
      const svgClock =
          '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle;margin-right:6px;flex-shrink:0;"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>';

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

      // ASCII int to Bengali digits
      String toBengali(int n) {
        const bn = '০১২৩৪৫৬৭৮৯';
        return n.toString().split('').map((c) => bn[int.parse(c)]).join('');
      }

      // Parse all deadline dates
      // Bengali date format: "০৪, ২১ জুন ও ০২ জুলাই ২০২৬ রাত ১১:৫৯ মিনিট"
      // "০৪, ২১ জুন" means both 4th and 21st are in June (shared month)
      // Must NOT split by comma first — that loses the month for bare day numbers
      final List<Map<String, dynamic>> allDeadlines = [];
      if (deadlineRaw.isNotEmpty) {
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);
        final Map<String, int> bengaliMonths = {
          'জানুয়ারি': 1,
          'ফেব্রুয়ারি': 2,
          'মার্চ': 3,
          'এপ্রিল': 4,
          'মে': 5,
          'জুন': 6,
          'জুলাই': 7,
          'আগস্ট': 8,
          'সেপ্টেম্বর': 9,
          'অক্টোবর': 10,
          'নভেম্বর': 11,
          'ডিসেম্বর': 12,
        };

        // Extract global year (e.g. ২০২৬)
        int? globalYear;
        String globalYearBengali = '';
        final yearMatch = RegExp(r'[০-৯]{4}').firstMatch(deadlineRaw);
        if (yearMatch != null) {
          globalYear = int.tryParse(toAscii(yearMatch.group(0)!));
          globalYearBengali = yearMatch.group(0)!;
        }

        // Step 1: Split by "ও" to get major segments
        // "০৪, ২১ জুন ও ০২ জুলাই ২০২৬ রাত ১১:৫৯ মিনিট"
        // → ["০৪, ২১ জুন", "০২ জুলাই ২০২৬ রাত ১১:৫৯ মিনিট"]
        final majorSegments = deadlineRaw.split(RegExp(r'\sও\s'));

        for (final segment in majorSegments) {
          final trimmedSeg = segment.trim();
          if (trimmedSeg.isEmpty) continue;

          // Find the month name in this segment
          String? segMonthName;
          int? segMonth;
          for (final entry in bengaliMonths.entries) {
            if (trimmedSeg.contains(entry.key)) {
              segMonthName = entry.key;
              segMonth = entry.value;
              break;
            }
          }
          if (segMonthName == null || segMonth == null) continue;

          // Step 2: Split segment by comma to handle "০৪, ২১ জুন"
          // → ["০৪", " ২১ জুন"]
          final subParts = trimmedSeg.split(',');

          for (final subPart in subParts) {
            final trimmedPart = subPart.trim();
            if (trimmedPart.isEmpty) continue;

            // Extract the first day number (1-2 Bengali digits)
            final dayMatch = RegExp(r'([০-৯]{1,2})').firstMatch(trimmedPart);
            if (dayMatch == null) continue;

            final bengaliDay = dayMatch.group(1)!;
            final day = int.tryParse(toAscii(bengaliDay));
            if (day == null || day > 31) continue;

            // Check if this sub-part has its own month name
            String usedMonthName = segMonthName;
            int usedMonth = segMonth;
            for (final entry in bengaliMonths.entries) {
              if (trimmedPart.contains(entry.key)) {
                usedMonthName = entry.key;
                usedMonth = entry.value;
                break;
              }
            }

            final usedYear = globalYear;
            if (usedYear == null) continue;

            final deadline = DateTime(usedYear, usedMonth, day);
            final diff = deadline.difference(todayOnly).inDays;
            final label = '$bengaliDay $usedMonthName $globalYearBengali';
            allDeadlines.add({'label': label, 'diff': diff});
          }
        }
        // Sort by diff ascending (nearest first)
        allDeadlines.sort(
          (a, b) => (a['diff'] as int).compareTo(b['diff'] as int),
        );
      }

      // Separate future deadlines from expired ones
      final List<Map<String, dynamic>> futureDeadlines = [];
      for (final d in allDeadlines) {
        if ((d['diff'] as int) >= 0) {
          futureDeadlines.add(d);
        }
      }

      // Determine if single or multiple deadline mode
      final bool isMultipleDeadlines = allDeadlines.length > 1;

      if (jobPostCategory.isNotEmpty ||
          vacancies.isNotEmpty ||
          allDeadlines.isNotEmpty) {
        acfHtml = '<div class="acf-box">';

        // === MULTIPLE DEADLINES LAYOUT (Screenshot 3) ===
        if (isMultipleDeadlines) {
          // চলমান নিয়োগ (only in multiple deadline mode, if available)
          if (runningCircular.isNotEmpty) {
            acfHtml +=
                '''
            <div class="acf-item">
              $svgDocument
              <span class="acf-label"> চলমান নিয়োগ: <span class="acf-value-red">$runningCircular</span></span>
            </div>''';
          }

          // পদ ক্যাটাগরি
          if (jobPostCategory.isNotEmpty) {
            acfHtml +=
                '''
            <div class="acf-item">
              $svgBook
              <span class="acf-label"> পদ ক্যাটাগরি: <span class="acf-value-black">$jobPostCategory</span></span>
            </div>''';
          }

          // মোট পদের সংখ্যা
          if (vacancies.isNotEmpty) {
            acfHtml +=
                '''
            <div class="acf-item">
              $svgUserPlus
              <span class="acf-label"> মোট পদের সং&zwnj;খ্যা: <span class="acf-value-green">$vacancies</span></span>
            </div>''';
          }

          // পরবর্তী আবেদনের শেষ তারিখ (nearest future deadline)
          if (futureDeadlines.isNotEmpty) {
            final nearest = futureDeadlines.first;
            final nearestDiff = nearest['diff'] as int;
            String nearestBadge;
            if (nearestDiff == 0) {
              nearestBadge =
                  '<span style="color:red;font-weight:bold;">আজই শেষ!</span>';
            } else {
              nearestBadge =
                  '<span style="color:red;font-weight:bold;">${toBengali(nearestDiff)} দিন বাকি</span>';
            }

            acfHtml +=
                '''
            <div class="acf-item">
              $svgCalendar
              <span class="acf-label"> পরবর্তী আবেদনের শেষ তারিখ:</span>
            </div>
            <div class="acf-item" style="margin-left:22px;">
              <span>${nearest['label']} → $nearestBadge</span>
            </div>''';

            // অন্যান্য আবেদনের শেষ তারিখ (remaining future deadlines)
            if (futureDeadlines.length > 1) {
              acfHtml +=
                  '''
              <div class="acf-item">
                $svgCalendar
                <span class="acf-label"> অন্যান্য আবেদনের শেষ তারিখ:</span>
              </div>''';

              for (int i = 1; i < futureDeadlines.length; i++) {
                final d = futureDeadlines[i];
                final diff = d['diff'] as int;
                String badge;
                if (diff == 0) {
                  badge =
                      '<span style="color:red;font-weight:bold;">আজই শেষ!</span>';
                } else {
                  badge =
                      '<span style="color:red;font-weight:bold;">${toBengali(diff)} দিন বাকি</span>';
                }
                acfHtml +=
                    '''
                <div class="acf-item" style="margin-left:22px;">
                  <span>${d['label']} → $badge</span>
                </div>''';
              }
            }
          } else {
            // All deadlines expired in multiple mode
            acfHtml +=
                '''
            <div class="acf-item">
              $svgCalendar
              <span class="acf-label" style="color:red;"> আবেদন শেষ</span>
            </div>''';
          }
        }
        // === SINGLE DEADLINE LAYOUT (Screenshot 2) ===
        else {
          // পদ ক্যাটাগরি
          if (jobPostCategory.isNotEmpty) {
            acfHtml +=
                '''
            <div class="acf-item">
              $svgBook
              <span class="acf-label"> পদ ক্যাটাগরি: <span class="acf-value-black">$jobPostCategory</span></span>
            </div>''';
          }

          // মোট পদের সংখ্যা
          if (vacancies.isNotEmpty) {
            acfHtml +=
                '''
            <div class="acf-item">
              $svgUserPlus
              <span class="acf-label"> মোট পদের সং&zwnj;খ্যা: <span class="acf-value-green">$vacancies</span></span>
            </div>''';
          }

          // Single deadline display
          if (allDeadlines.isNotEmpty) {
            final single = allDeadlines.first;
            final diff = single['diff'] as int;

            if (diff >= 0) {
              // আবেদনের সময় বাকি (clock icon)
              String timeLeftBadge;
              if (diff == 0) {
                timeLeftBadge = 'আজই শেষ!';
              } else {
                timeLeftBadge = '${toBengali(diff)} দিন';
              }
              acfHtml +=
                  '''
              <div class="acf-item">
                $svgClock
                <span class="acf-label"> আবেদনের সময় বাকি: <span class="acf-value-red">$timeLeftBadge</span></span>
              </div>''';

              // আবেদনের শেষ সময় (calendar icon, red label)
              acfHtml +=
                  '''
              <div class="acf-item">
                $svgCalendar
                <span class="acf-label acf-value-red"> আবেদনের শেষ সময়: <span class="acf-value-black" style="font-weight:bold;">${single['label']}</span></span>
              </div>''';
            } else {
              // Expired single deadline
              acfHtml +=
                  '''
              <div class="acf-item">
                $svgCalendar
                <span class="acf-label acf-value-red"> আবেদন শেষ</span>
              </div>''';
            }
          }
        }

        acfHtml += '</div>';
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

  /// Injects JavaScript to detect long-press on images and send URL to Flutter
  void _injectLongPressHandler() {
    controller.runJavaScript('''
      (function() {
        var images = document.querySelectorAll('img');
        images.forEach(function(img) {
          var timer;
          var moved = false;
          img.addEventListener('touchstart', function(e) {
            moved = false;
            timer = setTimeout(function() {
              if (!moved) {
                e.preventDefault();
                ImageSaver.postMessage(img.src);
              }
            }, 600);
          }, {passive: false});
          img.addEventListener('touchend', function() {
            clearTimeout(timer);
          });
          img.addEventListener('touchmove', function() {
            moved = true;
            clearTimeout(timer);
          });
        });
      })();
    ''');
  }

  /// Shows a bottom sheet with option to save image to gallery
  void _showSaveImageDialog(String imageUrl) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.download_rounded,
                    color: Colors.green,
                  ),
                  title: const Text('ছবি গ্যালারিতে সেভ করুন'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _saveImageToGallery(imageUrl);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.open_in_browser,
                    color: Colors.blue,
                  ),
                  title: const Text('ব্রাউজারে খুলুন'),
                  onTap: () {
                    Navigator.pop(ctx);
                    InAppBrowser.openUrl(context, imageUrl);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.grey),
                  title: const Text('বাতিল'),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Downloads image from URL and saves it to the device gallery
  Future<void> _saveImageToGallery(String imageUrl) async {
    try {
      Fluttertoast.showToast(
        msg: "ডাউনলোড হচ্ছে...",
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
      );

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();

        // Determine extension from URL or content-type
        String ext = 'jpg';
        final lowerUrl = imageUrl.toLowerCase();
        if (lowerUrl.contains('.png')) {
          ext = 'png';
        } else if (lowerUrl.contains('.webp')) {
          ext = 'webp';
        } else if (lowerUrl.contains('.jpeg')) {
          ext = 'jpeg';
        }

        final fileName =
            'job_circular_${DateTime.now().millisecondsSinceEpoch}.$ext';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        // Request gallery access and save
        await Gal.requestAccess();
        await Gal.putImage(file.path);

        // Clean up temp file
        await file.delete();

        if (mounted) {
          Fluttertoast.showToast(
            msg: "ছবি গ্যালারিতে সেভ হয়েছে ✓",
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        }
      } else {
        throw Exception('Download failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error saving image: $e');
      if (mounted) {
        Fluttertoast.showToast(
          msg: "ছবি সেভ করা যায়নি",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(title),
        actions: [
          Consumer<FavouritesProvider>(
            builder: (context, favProvider, child) {
              final isfav = favProvider.isFavourite(title);
              return IconButton(
                tooltip: 'Add To Favourites',
                onPressed: () async {
                  final post = SinglePost(
                    title: title,
                    img: image,
                    content: widget.content,
                    category: category,
                    date: date,
                    acf: widget.acf is Map ? widget.acf as Map : null,
                  );

                  if (isfav) {
                    favProvider.removeFavourite(title);
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
                    favProvider.addFavourite(post);
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
              );
            },
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
