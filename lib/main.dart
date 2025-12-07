import 'dart:async';
import 'package:flutter/material.dart';
import 'package:portfolio_website/viewmodels/activity_viewmodel.dart';
import 'package:portfolio_website/viewmodels/social_links_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'theme/app_theme.dart';
import 'config/firebase_config.dart';
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
  
  // Start app immediately, initialize Firebase in background
  await loadFonts();
  runApp(const MyApp());
  
  // Initialize Firebase in background (non-blocking)
  initializeFirebaseWithTimeout().catchError((e) {
    debugPrint('Failed to initialize Firebase: $e');
  });
}

// Initialize Firebase with timeout and proper error handling
Future<void> initializeFirebaseWithTimeout() async {
  // Create a completer to properly handle the initialization
  Completer<bool> initCompleter = Completer<bool>();
  
  // Set a timeout for Firebase initialization (reduced from 10 to 5 seconds)
  Timer? timeoutTimer = Timer(const Duration(seconds: 5), () {
    if (!initCompleter.isCompleted) {
      debugPrint('Firebase initialization timed out, continuing without Firebase');
      initCompleter.complete(false);
    }
  });
  
  try {
    // Validate Firebase config
    if (!FirebaseConfig.isValid) {
      throw Exception('Firebase configuration is invalid. Please check environment variables.');
    }
    
    // Try to initialize Firebase using environment variables
    await Firebase.initializeApp(
      options: FirebaseConfig.options,
    );
    
    if (!initCompleter.isCompleted) {
      useFirebase = true;
      initCompleter.complete(true);
    }
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
    if (!initCompleter.isCompleted) {
      initCompleter.complete(false);
    }
  }
  
  // Wait for either successful initialization or timeout
  bool firebaseInitialized = await initCompleter.future;
  timeoutTimer.cancel();
  
  if (firebaseInitialized) {
    useFirebase = true;
    
    // Enable Firestore offline persistence
    try {
      final firestore = FirebaseFirestore.instance;
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      debugPrint('Firestore offline persistence enabled');
    } catch (e) {
      debugPrint('Failed to enable Firestore offline persistence: $e');
    }
    
    // Initialize Analytics if available
    try {
      final analytics = FirebaseAnalytics.instance;
      analytics.logAppOpen();
    } catch (e) {
      debugPrint('Analytics not initialized: $e');
    }
    
    // Initialize Firestore collections in background (don't block app startup)
    FirestoreSetupService().initializeFirestore().catchError((e) {
      debugPrint('Failed to initialize Firestore collections: $e');
    });
  } else {
    useFirebase = false;
  }
}

// This function is no longer needed - app starts immediately now

// Load required fonts
Future<void> loadFonts() async {
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.jetBrainsMonoTextTheme(),
      GoogleFonts.robotoTextTheme(),
      GoogleFonts.firaSansTextTheme(),
    ]);
  } catch (e) {
    debugPrint('Font loading error: $e');
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
    debugPrint('Error launching URL: $e');
    // You could also show a snackbar or dialog here to inform the user
  }
}