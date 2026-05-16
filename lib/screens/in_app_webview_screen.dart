import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility class to open URLs in Chrome Custom Tabs (Android) / SFSafariViewController (iOS).
///
/// This provides a native browser experience with:
/// - Full download support (PDF, images, files)
/// - Long-press to save images
/// - All link types supported
/// - Smooth, native performance
/// - Swipe/back to return to the app
class InAppBrowser {
  /// Opens the given [url] in Chrome Custom Tabs (Android) or SFSafariViewController (iOS).
  ///
  /// Falls back to external browser if in-app browser is not available.
  static Future<void> openUrl(BuildContext context, String url) async {
    String finalUrl = url.trim();

    // Ensure the URL has a scheme
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      finalUrl = 'https://$finalUrl';
    }

    try {
      final uri = Uri.parse(finalUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );

      if (!launched) {
        // Fallback to external browser if in-app browser view fails
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      Fluttertoast.showToast(
        msg: "লিংক খোলা যাচ্ছে না",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
