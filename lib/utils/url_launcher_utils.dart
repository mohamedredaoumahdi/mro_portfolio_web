// lib/utils/url_launcher_utils.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Utility class for URL handling
class UrlLauncherUtils {
  /// Launch a URL with proper error handling
  static Future<bool> launchURL(
    String url, {
    LaunchMode mode = LaunchMode.externalApplication,
    bool showErrorSnackbar = true,
    BuildContext? context,
  }) async {
    // Make sure URL has protocol
    final urlToLaunch = url.startsWith('http') ? url : 'https://$url';
    
    try {
      final canLaunch = await canLaunchUrlString(urlToLaunch);
      
      if (canLaunch) {
        return await launchUrlString(
          urlToLaunch,
          mode: mode,
        );
      } else {
        throw 'Could not launch $urlToLaunch';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      
      // Show snackbar if context is provided and showErrorSnackbar is true
      if (showErrorSnackbar && context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $urlToLaunch'),
            action: SnackBarAction(
              label: 'Copy',
              onPressed: () {
                // Add clipboard functionality
                // Clipboard.setData(ClipboardData(text: urlToLaunch));
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('URL copied to clipboard')),
                // );
              },
            ),
          ),
        );
      }
      
      return false;
    }
  }
  
  /// Check if a URL is valid
  static bool isValidUrl(String url) {
    final urlRegExp = RegExp(
      r'^(https?:\/\/)?' // protocol
      r'((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|' // domain name
      r'((\d{1,3}\.){3}\d{1,3}))' // OR ip (v4) address
      r'(\:\d+)?(\/[-a-z\d%_.~+]*)*' // port and path
      r'(\?[;&a-z\d%_.~+=-]*)?' // query string
      r'(\#[-a-z\d_]*)?$', // fragment locator
      caseSensitive: false,
    );
    
    return urlRegExp.hasMatch(url);
  }
  
  /// Extract domain from URL
  static String extractDomain(String url) {
    if (url.isEmpty) return '';
    
    // Ensure URL has a protocol
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    
    try {
      // Parse URL and extract host
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      debugPrint('Error extracting domain: $e');
      return url;
    }
  }
  
  /// Create email link
  static String createEmailLink(String email, {String? subject, String? body}) {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters({
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }),
    );
    
    return emailUri.toString();
  }
  
  /// Helper to encode query parameters
  static String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}