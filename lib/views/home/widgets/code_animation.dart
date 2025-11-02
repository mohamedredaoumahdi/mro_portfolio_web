import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../viewmodels/theme_viewmodel.dart';

class CodeAnimation extends StatefulWidget {
  const CodeAnimation({super.key});

  @override
  State<CodeAnimation> createState() => _CodeAnimationState();
}

class _CodeAnimationState extends State<CodeAnimation> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final bool _isActive = true;
  Timer? _timer;
  late final AnimationController _fadeController;
  
  final List<String> _codeSnippets = [
    '''
class Portfolio {
  final String name;
  final List<Project> projects;
  
  Portfolio({
    required this.name,
    required this.projects,
  });
  
  void showcase() {
    print("Welcome to my portfolio!");
    for (var project in projects) {
      project.display();
    }
  }
}
''',
    '''
Future<void> buildApp() async {
  final ui = await DesignSystem.create();
  final api = await ApiService.initialize();
  
  MobileApp app = MobileApp(
    theme: ui.darkTheme,
    services: [api, analytics],
  );
  
  await app.run();
  print("App launched successfully!");
}
''',
    '''
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: AnimatedContainer(
      duration: Duration(milliseconds: 500),
      color: isDarkMode ? Colors.black : Colors.white,
      child: Center(
        child: Text("Hello, World!"),
      ),
    ),
  );
}
''',
  ];

  // Pre-processed code for better performance
  List<List<Widget>> _darkModeLines = [];
  List<List<Widget>> _lightModeLines = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize fade animation controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Start with fade in
    _fadeController.forward();
    
    // Start animation timer
    _startAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Pre-process code snippets after dependencies are ready
    _processAllSnippets();
  }

  void _processAllSnippets() {
    _darkModeLines = [];
    _lightModeLines = [];
    
    for (final snippet in _codeSnippets) {
      List<Widget> darkLines = [];
      List<Widget> lightLines = [];
      
      final lines = snippet.split('\n');
      for (final line in lines) {
        darkLines.add(_buildSyntaxLine(line, isDarkMode: true));
        lightLines.add(_buildSyntaxLine(line, isDarkMode: false));
      }
      
      _darkModeLines.add(darkLines);
      _lightModeLines.add(lightLines);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted) {
        // Start fade out animation
        _fadeController.reverse().then((_) {
          // When fade out completes, change content and fade in
          setState(() {
            _currentIndex = (_currentIndex + 1) % _codeSnippets.length;
          });
          _fadeController.forward();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeViewModel>(context).isDarkMode;
    
    return FadeTransition(
      opacity: _fadeController,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 400,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode 
              ? Colors.black.withOpacity(0.7)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
          border: Border.all(
            color: isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const Spacer(),
                Text(
                  'code_sample.dart',
                  style: TextStyle(
                    color: isDarkMode 
                        ? Colors.white.withOpacity(0.7) 
                        : Colors.black.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: RepaintBoundary(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _getCodeLines(isDarkMode),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Get the pre-processed code lines for the current index
  List<Widget> _getCodeLines(bool isDarkMode) {
    if (_darkModeLines.isEmpty || _lightModeLines.isEmpty) {
      // If processing hasn't completed yet
      final lines = _codeSnippets[_currentIndex].split('\n');
      return lines.map((line) => _buildSyntaxLine(line, isDarkMode: isDarkMode)).toList();
    }
    
    return isDarkMode 
      ? _darkModeLines[_currentIndex] 
      : _lightModeLines[_currentIndex];
  }

  // Build syntax highlighted line
  Widget _buildSyntaxLine(String line, {required bool isDarkMode}) {
    // Keyword colors based on theme
    const Color keywordColor = Color(0xFF569CD6); // Blue
    const Color typeColor = Color(0xFF4EC9B0);    // Teal
    const Color stringColor = Color(0xFFCE9178);  // Orange
    final Color normalColor = isDarkMode ? Colors.white70 : Colors.black87;
    
    // Prepare spans for line
    List<InlineSpan> spans = [];
    
    // Find string literals with regex
    final RegExp stringRegex = RegExp(r'"[^"]*"' r"|'[^']*'");
    final matches = stringRegex.allMatches(line);
    
    // Process line with strings
    int lastPosition = 0;
    for (final match in matches) {
      // Add text before string with keyword highlighting
      if (match.start > lastPosition) {
        final beforeText = line.substring(lastPosition, match.start);
        spans.add(_createTextSpan(beforeText, normalColor, keywordColor, typeColor));
      }
      
      // Add the string literal
      spans.add(TextSpan(
        text: line.substring(match.start, match.end),
        style: TextStyle(
          color: stringColor,
          fontFamily: 'JetBrainsMono',
          fontSize: 14,
          height: 1.5,
        ),
      ));
      
      lastPosition = match.end;
    }
    
    // Add remaining text after last string
    if (lastPosition < line.length) {
      final remainingText = line.substring(lastPosition);
      spans.add(_createTextSpan(remainingText, normalColor, keywordColor, typeColor));
    }
    
    // Return the styled line
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: normalColor,
          fontFamily: 'JetBrainsMono',
          fontSize: 14,
          height: 1.5,
        ),
        children: spans,
      ),
    );
  }
  
  // Create text span with keyword highlighting
  InlineSpan _createTextSpan(String text, Color normalColor, Color keywordColor, Color typeColor) {
    // Keywords to highlight
    final Map<String, Color> keywords = {
      'class': keywordColor,
      'void': keywordColor,
      'final': keywordColor,
      'const': keywordColor,
      'var': keywordColor,
      'for': keywordColor,
      'if': keywordColor,
      'else': keywordColor,
      'await': keywordColor,
      'async': keywordColor,
      'required': keywordColor,
      'return': keywordColor,
      'print': keywordColor,
      '@override': keywordColor,
      'Future': typeColor,
      'String': typeColor,
      'List': typeColor,
      'BuildContext': typeColor,
      'Widget': typeColor,
      'Scaffold': typeColor,
      'AnimatedContainer': typeColor,
      'Center': typeColor,
      'Duration': typeColor,
      'Text': typeColor,
    };
    
    // Check for keywords
    for (final entry in keywords.entries) {
      if (text.contains(entry.key) &&
          (text == entry.key || 
           text.startsWith('${entry.key} ') || 
           text.endsWith(' ${entry.key}') || 
           text.contains(' ${entry.key} '))) {
        
        // Simple highlighting for exact keyword match
        return TextSpan(
          text: text,
          style: TextStyle(
            color: entry.value,
            fontWeight: entry.value == keywordColor ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }
    }
    
    // Return regular text if no keywords found
    return TextSpan(text: text);
  }
}