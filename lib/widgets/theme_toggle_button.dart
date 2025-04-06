// lib/widgets/theme_toggle_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_viewmodel.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool showLabel;
  final bool isInAppBar;
  
  const ThemeToggleButton({
    super.key, 
    this.showLabel = false,
    this.isInAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeViewModel, child) {
        return InkWell(
          onTap: () => themeViewModel.toggleTheme(),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12, 
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isInAppBar 
                  ? Colors.transparent 
                  : Theme.of(context).colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(50),
              border: isInAppBar 
                  ? null 
                  : Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  themeViewModel.isDarkMode 
                      ? Icons.light_mode 
                      : Icons.dark_mode,
                  size: 20,
                  color: isInAppBar 
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.primary,
                ),
                if (showLabel) ...[
                  const SizedBox(width: 8),
                  Text(
                    themeViewModel.isDarkMode ? 'Light Mode' : 'Dark Mode',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}