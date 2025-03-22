import 'package:flutter/material.dart';
import '../../../models/project_model.dart';

class ServiceCard extends StatefulWidget {
  final Service service;

  const ServiceCard({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isHovered
              ? Theme.of(context).colorScheme.surface.withOpacity(0.8)
              : Theme.of(context).colorScheme.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      _getIconForService(widget.service.title),
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.service.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _isHovered
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.service.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
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
    } else {
      return Icons.code;
    }
  }
}