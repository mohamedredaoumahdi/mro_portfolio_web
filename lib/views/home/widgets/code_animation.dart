import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../viewmodels/theme_viewmodel.dart';

class CodeAnimation extends StatefulWidget {
  const CodeAnimation({super.key});

  @override
  State<CodeAnimation> createState() => _CodeAnimationState();
}

class _CodeAnimationState extends State<CodeAnimation> {
  int _currentIndex = 0;
  bool _isActive = true;
  Timer? _timer;
  
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

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted) {
        setState(() {
          _isActive = false;
        });
        
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _currentIndex = (_currentIndex + 1) % _codeSnippets.length;
              _isActive = true;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeViewModel>(context).isDarkMode;
    
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isActive ? 1.0 : 0.0,
      child: Container(
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
              child: _buildCodeText(_codeSnippets[_currentIndex], isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeText(String code, bool isDarkMode) {
    // Add colored syntax highlighting
    final lines = code.split('\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // Basic syntax highlighting
        if (line.contains('class ') || line.contains('void ') || line.contains('Future<') || line.contains('@override')) {
          return _buildSyntaxLine(line, isKeyword: true, isDarkMode: isDarkMode);
        } else if (line.contains('=') || line.contains('(') || line.contains(')') || line.contains('{') || line.contains('}')) {
          return _buildSyntaxLine(line, isDarkMode: isDarkMode);
        } else {
          return Text(
            line,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              height: 1.5,
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildSyntaxLine(String line, {bool isKeyword = false, required bool isDarkMode}) {
    final keywords = ['class', 'void', 'final', 'const', 'var', 'for', 'if', 'else', 'await', 'async', 'required', 'return', 'Future', 'Widget', 'BuildContext', 'override'];
    final types = ['String', 'List', 'int', 'bool', 'double', 'Map', 'Set', 'Duration', 'Color', 'ThemeData'];
    
    String formattedLine = line;
    
    if (isKeyword) {
      for (final keyword in keywords) {
        if (line.contains(keyword)) {
          formattedLine = formattedLine.replaceAll(keyword, '<keyword>$keyword</keyword>');
        }
      }
      
      for (final type in types) {
        if (line.contains(type)) {
          formattedLine = formattedLine.replaceAll(type, '<type>$type</type>');
        }
      }
    }
    
    if (line.contains('"') || line.contains("'")) {
      final regex = RegExp(r'"[^"]*"');
      formattedLine = formattedLine.replaceAllMapped(regex, (match) {
        return '<string>${match.group(0)}</string>';
      });
      
      final regex2 = RegExp(r"'[^']*'");
      formattedLine = formattedLine.replaceAllMapped(regex2, (match) {
        return '<string>${match.group(0)}</string>';
      });
    }
    
    // Split by tags
    final parts = <Widget>[];
    
    int startIndex = 0;
    while (startIndex < formattedLine.length) {
      final keywordStart = formattedLine.indexOf('<keyword>', startIndex);
      final typeStart = formattedLine.indexOf('<type>', startIndex);
      final stringStart = formattedLine.indexOf('<string>', startIndex);
      
      int nextTagStart = _minPositive([
        keywordStart, 
        typeStart, 
        stringStart
      ]);
      
      if (nextTagStart == -1) {
        // No more tags, add the rest of the string
        parts.add(
          Text(
            formattedLine.substring(startIndex),
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              height: 1.5,
            ),
          ),
        );
        break;
      } else {
        // Add text before the tag
        if (nextTagStart > startIndex) {
          parts.add(
            Text(
              formattedLine.substring(startIndex, nextTagStart),
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontFamily: 'JetBrainsMono',
                fontSize: 14,
                height: 1.5,
              ),
            ),
          );
        }
        
        // Process the tag
        if (nextTagStart == keywordStart) {
          final endTag = formattedLine.indexOf('</keyword>', keywordStart);
          final content = formattedLine.substring(keywordStart + 9, endTag);
          parts.add(
            Text(
              content,
              style: const TextStyle(
                color: Color(0xFF569CD6), // Blue for keywords
                fontFamily: 'JetBrainsMono',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          );
          startIndex = endTag + 10;
        } else if (nextTagStart == typeStart) {
          final endTag = formattedLine.indexOf('</type>', typeStart);
          final content = formattedLine.substring(typeStart + 6, endTag);
          parts.add(
            Text(
              content,
              style: const TextStyle(
                color: Color(0xFF4EC9B0), // Teal for types
                fontFamily: 'JetBrainsMono',
                fontSize: 14,
                height: 1.5,
              ),
            ),
          );
          startIndex = endTag + 7;
        } else if (nextTagStart == stringStart) {
          final endTag = formattedLine.indexOf('</string>', stringStart);
          final content = formattedLine.substring(stringStart + 8, endTag);
          parts.add(
            Text(
              content,
              style: const TextStyle(
                color: Color(0xFFCE9178), // Orange for strings
                fontFamily: 'JetBrainsMono',
                fontSize: 14,
                height: 1.5,
              ),
            ),
          );
          startIndex = endTag + 9;
        }
      }
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts,
    );
  }
  
  int _minPositive(List<int> values) {
    int min = -1;
    for (final value in values) {
      if (value >= 0 && (min == -1 || value < min)) {
        min = value;
      }
    }
    return min;
  }
}