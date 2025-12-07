import 'package:flutter/material.dart';
import '../../../models/project_model.dart';

class ServiceCard extends StatefulWidget {
  final Service service;

  const ServiceCard({
    super.key,
    required this.service,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBackgroundColor = isDarkMode 
        ? Theme.of(context).colorScheme.surface
        : Colors.white;
    final borderColor = isDarkMode
        ? Colors.grey.withValues(alpha: 0.3)
        : Colors.grey.withValues(alpha: 0.2);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Transform.scale(
        scale: _isHovered ? 1.02 : 1.0,
        child: SizedBox(
          height: 320,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered 
                    ? borderColor // Grey on hover
                    : Theme.of(context).colorScheme.primary, // Purple when not hovering
                width: _isHovered ? 1.5 : 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: isDarkMode ? 0.2 : 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Circular icon container with hover animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: _isHovered ? 115 : 110,
              height: _isHovered ? 115 : 110,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: _isHovered ? 0.15 : 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: _isHovered ? 0.4 : 0.3),
                  width: _isHovered ? 1.5 : 1,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: AnimatedScale(
                  scale: _isHovered ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    _getIconForService(widget.service.title),
                    color: Theme.of(context).colorScheme.primary,
                    size: 50,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),
            // Title - bold, centered
            Text(
              widget.service.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isDarkMode 
                    ? Colors.white 
                    : Colors.grey[900],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            // Description - left-aligned, smaller grey text, max 3 lines
            Text(
              widget.service.description,
              textAlign: TextAlign.left,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? Colors.grey[400]
                    : Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForService(String title) {
    // Fallback icons in case asset images are not available
    if (title.contains('Mobile')) {
      return Icons.phone_android;
    } else if (title.contains('UI') || title.contains('UX')) {
      return Icons.design_services;
    } else if (title.contains('API')) {
      return Icons.api;
    } else if (title.contains('Maintenance')) {
      return Icons.build;
    } else if (title.contains('Flutter')) {
      return Icons.flutter_dash;
    } else if (title.contains('Firebase')) {
      return Icons.local_fire_department;
    } else if (title.contains('iOS') || title.contains('Swift')) {
      return Icons.phone_iphone;
    } else if (title.contains('Android')) {
      return Icons.android;
    } else {
      return Icons.code;
    }
  }
}