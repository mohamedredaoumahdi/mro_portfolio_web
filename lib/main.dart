import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'theme/app_theme.dart';
import 'viewmodels/project_viewmodel.dart';
import 'viewmodels/service_viewmodel.dart';
import 'views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load Google Fonts
  await GoogleFonts.pendingFonts([
    GoogleFonts.jetBrainsMonoTextTheme(),
    GoogleFonts.robotoTextTheme(),
    GoogleFonts.firaSansTextTheme(),
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectViewModel()),
        ChangeNotifierProvider(create: (_) => ServiceViewModel()),
      ],
      child: MaterialApp(
        title: 'Developer Portfolio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const HomeScreen(),
      ),
    );
  }
}

// Utility function for launching URLs
Future<void> launchURL(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(
      url,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw 'Could not launch $url';
  }
}