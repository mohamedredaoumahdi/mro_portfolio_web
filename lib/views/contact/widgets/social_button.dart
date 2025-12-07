// lib/views/contact/widgets/social_button.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portfolio_website/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SocialButton extends StatefulWidget {
  final IconData icon;
  final String url;
  final String label;
  final Color? color;
  final String linkId; // Add this parameter to identify which social link

  const SocialButton({
    super.key,
    required this.icon,
    required this.url,
    required this.label,
    this.color,
    required this.linkId, // Make this required
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> {
  bool _isHovered = false;
  String _actualUrl = ''; // Store the actual URL from Firebase
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestUrl();
  }

  Future<void> _fetchLatestUrl() async {
    try {
      // Directly fetch the latest link from Firebase
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('social_links')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey(widget.linkId)) {
          setState(() {
            _actualUrl = data[widget.linkId] as String;
            _isLoading = false;
          });
          return;
        }
      }
      
      // Fallback to the provided URL if Firebase data isn't available
      setState(() {
        _actualUrl = widget.url;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching social link: $e');
      // Fallback to the provided URL on error
      setState(() {
        _actualUrl = widget.url;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: _isLoading ? null : () => launchURL(_actualUrl),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? (widget.color ?? Theme.of(context).colorScheme.primary)
                : (widget.color ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: _isHovered
                    ? Colors.white
                    : (widget.color ?? Theme.of(context).colorScheme.primary),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: _isHovered
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}