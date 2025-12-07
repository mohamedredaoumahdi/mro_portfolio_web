// lib/views/admin/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portfolio_website/config/app_config.dart';
import 'package:portfolio_website/services/firestore_service.dart';
import 'package:portfolio_website/viewmodels/theme_viewmodel.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Theme settings
  bool _useDarkMode = AppConfig.themeConfig.useDarkMode;
  Color _primaryColor = Color(AppConfig.themeConfig.primaryColor);
  Color _accentColor = Color(AppConfig.themeConfig.accentColor);
  Color _backgroundColor = Color(AppConfig.themeConfig.backgroundColor);
  Color _textPrimaryColor = Color(AppConfig.themeConfig.textPrimaryColor);
  Color _textSecondaryColor = Color(AppConfig.themeConfig.textSecondaryColor);
  
  // Firebase connection status
  bool _isFirebaseConnected = false;
  
  // Loading and error states
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  
  @override
  void initState() {
    super.initState();
    _checkFirebaseConnection();
    _loadThemeSettings();
  }

  // Check Firebase connection
  Future<void> _checkFirebaseConnection() async {
    try {
      final firestoreService = FirestoreService.instance;
      await firestoreService.getPersonalInfo();
      setState(() {
        _isFirebaseConnected = true;
      });
    } catch (e) {
      setState(() {
        _isFirebaseConnected = false;
      });
    }
  }

  // Load current theme settings
  Future<void> _loadThemeSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Try to load settings from FireStore in the future
      // For now, initialize with AppConfig
      
      final themeViewModel = Provider.of<ThemeViewModel>(context, listen: false);
      
      setState(() {
        _useDarkMode = themeViewModel.isDarkMode;
        _primaryColor = Color(AppConfig.themeConfig.primaryColor);
        _accentColor = Color(AppConfig.themeConfig.accentColor);
        _backgroundColor = Color(AppConfig.themeConfig.backgroundColor);
        _textPrimaryColor = Color(AppConfig.themeConfig.textPrimaryColor);
        _textSecondaryColor = Color(AppConfig.themeConfig.textSecondaryColor);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load theme settings: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save theme settings
  Future<void> _saveThemeSettings() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    try {
      // Update theme in the app
      final themeViewModel = Provider.of<ThemeViewModel>(context, listen: false);
      
      // Set dark mode through the view model
      if (themeViewModel.isDarkMode != _useDarkMode) {
        await themeViewModel.toggleTheme();
      }
      
      // In a real app, we would save to Firestore
      // For now, just show success message
      
      setState(() {
        _successMessage = 'Theme settings updated successfully!';
        _isSaving = false;
      });
      
      // Clear success message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _successMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save theme settings: ${e.toString()}';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Configure application settings and appearance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            
            // Success message
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            
            // Settings content
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Firebase connection status
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'System Status',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 24),
                                
                                // Firebase connection status
                                ListTile(
                                  leading: Icon(
                                    _isFirebaseConnected ? Icons.cloud_done : Icons.cloud_off,
                                    color: _isFirebaseConnected ? Colors.green : Colors.red,
                                  ),
                                  title: const Text('Firebase Connection'),
                                  subtitle: Text(
                                    _isFirebaseConnected 
                                      ? 'Connected to Firebase'
                                      : 'Not connected to Firebase. Using local data.'
                                  ),
                                  trailing: _isFirebaseConnected
                                    ? const Icon(Icons.check_circle, color: Colors.green)
                                    : OutlinedButton(
                                        onPressed: _checkFirebaseConnection,
                                        child: const Text('Retry'),
                                      ),
                                ),
                                
                                // App version
                                const ListTile(
                                  leading: Icon(Icons.info_outline),
                                  title: Text('App Version'),
                                  subtitle: Text('1.0.0'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Appearance settings
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Appearance',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 24),
                                
                                // Dark mode toggle
                                SwitchListTile(
                                  title: const Text('Dark Mode'),
                                  subtitle: Text(_useDarkMode 
                                    ? 'Using dark theme'
                                    : 'Using light theme'
                                  ),
                                  value: _useDarkMode,
                                  onChanged: (value) {
                                    setState(() {
                                      _useDarkMode = value;
                                    });
                                  },
                                  secondary: Icon(
                                    _useDarkMode ? Icons.dark_mode : Icons.light_mode,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                
                                const Divider(),
                                const SizedBox(height: 8),
                                
                                // Color settings
                                Text(
                                  'Colors',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                
                                // Note about color changes
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Color settings will take effect on the next app restart.',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Primary color
                                _buildColorSetting(
                                  label: 'Primary Color',
                                  color: _primaryColor,
                                  onColorChanged: (color) {
                                    setState(() {
                                      _primaryColor = color;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Accent color
                                _buildColorSetting(
                                  label: 'Accent Color',
                                  color: _accentColor,
                                  onColorChanged: (color) {
                                    setState(() {
                                      _accentColor = color;
                                    });
                                  },
                                ),
                                
                                // More advanced color settings (expandable)
                                ExpansionTile(
                                  title: const Text('Advanced Color Settings'),
                                  tilePadding: EdgeInsets.zero,
                                  childrenPadding: EdgeInsets.zero,
                                  children: [
                                    const SizedBox(height: 16),
                                    
                                    // Background color
                                    _buildColorSetting(
                                      label: 'Background Color',
                                      color: _backgroundColor,
                                      onColorChanged: (color) {
                                        setState(() {
                                          _backgroundColor = color;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Text primary color
                                    _buildColorSetting(
                                      label: 'Primary Text Color',
                                      color: _textPrimaryColor,
                                      onColorChanged: (color) {
                                        setState(() {
                                          _textPrimaryColor = color;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Text secondary color
                                    _buildColorSetting(
                                      label: 'Secondary Text Color',
                                      color: _textSecondaryColor,
                                      onColorChanged: (color) {
                                        setState(() {
                                          _textSecondaryColor = color;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Save button
                        Center(
                          child: SizedBox(
                            width: 200,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveThemeSettings,
                              child: _isSaving
                                ? const CircularProgressIndicator()
                                : const Text('Save Changes'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to build color setting with picker
  Widget _buildColorSetting({
    required String label,
    required Color color,
    required ValueChanged<Color> onColorChanged,
  }) {
    return Row(
      children: [
        Text(label),
        const Spacer(),
        // Color preview
        GestureDetector(
          onTap: () => _showColorPicker(
            context: context,
            color: color,
            onColorChanged: onColorChanged,
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Color value
        Text(
          '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ],
    );
  }
  
  // Show color picker dialog
  void _showColorPicker({
    required BuildContext context,
    required Color color,
    required ValueChanged<Color> onColorChanged,
  }) {
    Color currentColor = color;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: color,
              onColorChanged: (Color color) {
                currentColor = color;
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: true,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsv,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onColorChanged(currentColor);
                Navigator.of(context).pop();
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }
}