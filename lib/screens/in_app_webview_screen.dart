import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InAppWebViewScreen extends StatefulWidget {
  final String url;

  const InAppWebViewScreen({super.key, required this.url});

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  late WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Webview Error: ${error.description}');
            Fluttertoast.showToast(
              msg: "Error: ${error.description}",
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
            setState(() {
              isLoading = false;
            });
          },
        ),
      );

    // Delaying the loadRequest to prevent SurfaceView buffer exhaustion
    // which happens when two WebViews are active during a page transition.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        String finalUrl = widget.url.trim();
        debugPrint('Loading URL in InAppWebView: $finalUrl');

        // Ensure the URL has a scheme
        if (!finalUrl.startsWith('http://') &&
            !finalUrl.startsWith('https://')) {
          finalUrl = 'https://$finalUrl';
        }

        // Android WebView does not natively support PDF viewing.
        // If it's a PDF, use Google Docs Viewer to render it inside the WebView.
        if (finalUrl.toLowerCase().endsWith('.pdf') ||
            finalUrl.toLowerCase().contains('.pdf?')) {
          finalUrl =
              'https://docs.google.com/gview?embedded=true&url=$finalUrl';
        }

        try {
          final lowerUrl = finalUrl.toLowerCase();
          bool isImage =
              lowerUrl.endsWith('.jpg') ||
              lowerUrl.endsWith('.jpeg') ||
              lowerUrl.endsWith('.png') ||
              lowerUrl.endsWith('.webp') ||
              lowerUrl.contains('.jpg?') ||
              lowerUrl.contains('.jpeg?') ||
              lowerUrl.contains('.png?') ||
              lowerUrl.contains('.webp?');

          if (isImage) {
            // Load direct image URLs inside an HTML wrapper to fit the screen
            final String htmlContent =
                '''
              <!DOCTYPE html>
              <html>
              <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">
                <style>
                  body { margin: 0; padding: 0; background-color: #111; display: flex; justify-content: center; align-items: center; height: 100vh; }
                  img { max-width: 100%; max-height: 100vh; object-fit: contain; }
                </style>
              </head>
              <body>
                <img src="$finalUrl" alt="Image" />
              </body>
              </html>
            ''';
            controller.loadHtmlString(htmlContent);
          } else {
            controller.loadRequest(Uri.parse(finalUrl));
          }
        } catch (e) {
          debugPrint('Error parsing URL: $e');
          Fluttertoast.showToast(msg: "Invalid URL");
          setState(() {
            isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
