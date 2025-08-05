import 'dart:async';
import 'package:flutter/material.dart';
import 'package:portfolio_website/viewmodels/activity_viewmodel.dart';
import 'package:portfolio_website/viewmodels/social_links_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'theme/app_theme.dart';
import 'viewmodels/project_viewmodel.dart';
import 'viewmodels/service_viewmodel.dart';
import 'viewmodels/contact_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'services/auth_service.dart';
import 'services/firestore_setup_service.dart';
import 'views/home/home_screen.dart';
import 'views/projects/project_details_page.dart';
import 'models/project_model.dart';
import 'routes/admin_routes.dart';

// Flag to track whether we're using Firebase
bool useFirebase = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Try initializing Firebase with proper error handling
    await initializeFirebaseWithTimeout();
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    runAppWithoutFirebase();
  }
}

// Initialize Firebase with timeout and proper error handling
Future<void> initializeFirebaseWithTimeout() async {
  // Create a completer to properly handle the initialization
  Completer<bool> initCompleter = Completer<bool>();
  
  // Set a timeout for Firebase initialization
  Timer? timeoutTimer = Timer(const Duration(seconds: 10), () {
    if (!initCompleter.isCompleted) {
      print('Firebase initialization timed out, continuing without Firebase');
      initCompleter.complete(false);
    }
  });
  
  try {
    // Try to initialize Firebase
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDIEiJa91VRseWa3udLSfN0bhAKhezssQc",
        authDomain: "myportfolio-594b1.firebaseapp.com",
        projectId: "myportfolio-594b1",
        storageBucket: "myportfolio-594b1.firebasestorage.app",
        messagingSenderId: "115489897719",
        appId: "1:115489897719:web:4337415f01a45598c027f2",
      ),
    );
    
    if (!initCompleter.isCompleted) {
      useFirebase = true;
      initCompleter.complete(true);
    }
  } catch (e) {
    print('Error initializing Firebase: $e');
    if (!initCompleter.isCompleted) {
      initCompleter.complete(false);
    }
  }
  
  // Wait for either successful initialization or timeout
  bool firebaseInitialized = await initCompleter.future;
  timeoutTimer.cancel();
  
  if (firebaseInitialized) {
    // Initialize Analytics if available
    try {
      final analytics = FirebaseAnalytics.instance;
      analytics.logAppOpen();
    } catch (e) {
      print('Analytics not initialized: $e');
    }
    
    // Initialize Firestore collections
    try {
      final firestoreSetupService = FirestoreSetupService();
      await firestoreSetupService.initializeFirestore();
    } catch (e) {
      print('Failed to initialize Firestore collections: $e');
      // Continue with app startup even if collection initialization fails
    }
    
    // Continue with loading fonts and running the app
    await loadFonts();
    runApp(const MyApp());
  } else {
    runAppWithoutFirebase();
  }
}

// Fallback to run app without Firebase
void runAppWithoutFirebase() async {
  useFirebase = false;
  await loadFonts();
  runApp(const MyApp());
}

// Load required fonts
Future<void> loadFonts() async {
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.jetBrainsMonoTextTheme(),
      GoogleFonts.robotoTextTheme(),
      GoogleFonts.firaSansTextTheme(),
    ]);
  } catch (e) {
    print('Font loading error: $e');
    // Continue without custom fonts if there's an error
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectViewModel()),
        ChangeNotifierProvider(create: (_) => ServiceViewModel()),
        ChangeNotifierProvider(create: (_) => ContactViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => SocialLinksViewModel()),
        ChangeNotifierProvider(create: (_) => ActivityViewModel()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return MaterialApp(
            title: 'Mohamed Reda Oumahdi - Mobile App Developer',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(isDarkMode: themeViewModel.isDarkMode),
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/project-details': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                if (args == null || args is! Map<String, dynamic>) {
                  // If no arguments provided, redirect to home
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacementNamed(context, '/');
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                final project = args['project'] as Project?;
                if (project == null) {
                  // If no project provided, redirect to home
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacementNamed(context, '/');
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return ProjectDetailsPage(project: project);
              },
              ...AdminRoutes.getRoutes(),
            },
          );
        },
      ),
    );
  }
}

// Utility function for launching URLs with improved error handling
Future<void> launchURL(String url) async {
  // Make sure URL has protocol
  final urlToLaunch = url.startsWith('http') ? url : 'https://$url';
  
  try {
    if (await canLaunchUrlString(urlToLaunch)) {
      await launchUrlString(
        urlToLaunch,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $urlToLaunch';
    }
  } catch (e) {
    print('Error launching URL: $e');
    // You could also show a snackbar or dialog here to inform the user
  }
}